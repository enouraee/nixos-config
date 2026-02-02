#!/usr/bin/env bash
#
# NixOS Installation Script with LUKS Encryption
# ================================================
# This script will:
#   1. Run preflight checks (network, flake validation, build test)
#   2. Partition the disk (GPT: EFI + encrypted root)
#   3. Setup LUKS encryption on root partition
#   4. Format filesystems (FAT32 for EFI, ext4 for root)
#   5. Mount partitions
#   6. Generate hardware configuration
#   7. Install NixOS with this flake
#
# Usage:
#   sudo ./install.sh /dev/sdX        # Replace sdX with your target disk
#   sudo ./install.sh /dev/nvme0n1    # For NVMe drives
#
# Environment Variables:
#   FORCE=1  - Skip partition existence check (DANGER: reformats existing partitions)
#   SKIP_BUILD_TEST=1 - Skip the pre-install build test (faster but less safe)
#
# WARNING: This will ERASE ALL DATA on the target disk!

set -euo pipefail

# Global error trap to prevent silent exits - outputs to stderr
trap 'echo -e "\n\033[0;31m[ERROR]\033[0m line $LINENO: $BASH_COMMAND" >&2' ERR

# Enable flakes and nix-command (works in NixOS live/installer environments)
export NIX_CONFIG="${NIX_CONFIG:-experimental-features = nix-command flakes}"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Configuration
HOST="expertbook"                    # Change if using different host
EFI_SIZE="512M"                      # EFI partition size
MAPPER_NAME="cryptroot"              # LUKS mapper name

# Get the script's directory (where the flake is)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# Source repo and target install paths
SRC_DIR="${SRC_DIR:-$SCRIPT_DIR}"
TARGET_DIR="${TARGET_DIR:-/mnt/etc/nixos}"
# REPO_DIR will point to the path used for flake operations; default to SRC_DIR
REPO_DIR="${REPO_DIR:-$SRC_DIR}"

log_info()  { echo -e "${BLUE}[INFO]${NC} $1"; }
log_ok()    { echo -e "${GREEN}[OK]${NC} $1"; }
log_warn()  { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }
log_step()  { echo -e "${CYAN}[STEP]${NC} $1"; }

# ====== PREFLIGHT CHECKS ======
preflight_checks() {
    log_step "Running preflight checks..."
    local failed=0
    
    # Check 1: flake.lock exists
    if [[ ! -f "$SCRIPT_DIR/flake.lock" ]]; then
        log_error "PREFLIGHT FAILED: flake.lock not found!"
        echo "  This is required for reproducible builds."
        echo "  Run: cd $SCRIPT_DIR && nix flake lock"
        failed=1
    else
        log_ok "flake.lock exists"
    fi
    
    # Check 2: Network connectivity (required for nixos-install)
    if ! ping -c 1 -W 3 cache.nixos.org &>/dev/null; then
        log_error "PREFLIGHT FAILED: Cannot reach cache.nixos.org"
        echo "  Network connection is required for installation."
        echo "  Check your network configuration."
        failed=1
    else
        log_ok "Network connectivity OK (cache.nixos.org reachable)"
    fi
    
    # Check 3: Validate flake metadata
    log_info "Validating flake metadata..."
    local metadata_output
    log_info "Using flake at: $REPO_DIR"
    # show metadata (best-effort) to help debugging
    nix flake metadata "$REPO_DIR" 2>/dev/null || true
    if ! metadata_output=$(nix flake metadata "$REPO_DIR" 2>&1); then
        log_error "PREFLIGHT FAILED: Flake metadata validation failed!"
        echo "  The flake may have syntax errors or invalid inputs."
        
        # Check for narHash mismatch
        if echo "$metadata_output" | grep -q "narHash"; then
            echo ""
            log_error "Detected narHash mismatch in flake.lock!"
            echo "  Your flake.lock is inconsistent with the actual inputs."
            echo ""
            echo "  FIX THIS BEFORE RUNNING THE INSTALLER:"
            echo "    cd $SCRIPT_DIR && nix flake lock --refresh"
            echo ""
            echo "  The installer will NOT auto-fix this to ensure reproducibility."
            exit 2
        fi

        failed=1
    else
        log_ok "Flake metadata valid"
    fi
    
    # Check 4: Verify host exists in flake (use nix flake show --json)
    log_info "Checking if host '$HOST' exists in flake..."
    local flake_json
    if flake_json=$(nix flake show --json "$SCRIPT_DIR" 2>/dev/null); then
        if echo "$flake_json" | grep -q "\"nixosConfigurations\".*\"$HOST\""; then
            log_ok "Host '$HOST' found in flake"
        else
            log_error "PREFLIGHT FAILED: Host '$HOST' not found in flake!"
            echo "  Available hosts:"
            echo "$flake_json" | grep -o '"nixosConfigurations":{[^}]*}' | grep -o '"[^"]*":' | grep -v nixosConfigurations || echo "  (none found)"
            failed=1
        fi
    else
        log_warn "Could not parse flake output, trying alternative check..."
        if nix eval "$SCRIPT_DIR#nixosConfigurations.$HOST.config.system.name" &>/dev/null; then
            log_ok "Host '$HOST' found in flake (via eval)"
        else
            log_error "PREFLIGHT FAILED: Host '$HOST' not found in flake!"
            failed=1
        fi
    fi
    
    # Check 5: Build test - will be run from the target ($TARGET_DIR) after copying configs
    if [[ "${SKIP_BUILD_TEST:-0}" != "1" ]]; then
        log_warn "Build test deferred until after copying repository to $TARGET_DIR"
    else
        log_warn "Skipping build test (SKIP_BUILD_TEST=1)"
    fi
    
    # Check 6: Required tools
    for cmd in parted cryptsetup mkfs.vfat mkfs.ext4 nixos-install nixos-generate-config; do
        if ! command -v "$cmd" &>/dev/null; then
            log_error "PREFLIGHT FAILED: Required command not found: $cmd"
            failed=1
        fi
    done
    [[ $failed -eq 0 ]] && log_ok "All required tools available"
    
    if [[ $failed -ne 0 ]]; then
        echo ""
        log_error "Preflight checks failed. Fix the issues above and try again."
        exit 1
    fi
    
    log_ok "All preflight checks passed!"
    echo ""
}

# Check if running as root
if [[ $EUID -ne 0 ]]; then
    log_error "This script must be run as root (use sudo)"
    exit 1
fi

# Check arguments
if [[ $# -lt 1 ]]; then
    echo "Usage: $0 <disk> [host]"
    echo "  disk: Target disk (e.g., /dev/sda, /dev/nvme0n1)"
    echo "  host: Host name (default: expertbook)"
    echo ""
    echo "Environment variables:"
    echo "  FORCE=1           - Force reformat even if partitions exist"
    echo "  SKIP_BUILD_TEST=1 - Skip the pre-install build test"
    echo ""
    echo "Available disks:"
    lsblk -d -o NAME,SIZE,MODEL | grep -v loop
    exit 1
fi

DISK="$1"
HOST="${2:-$HOST}"

# Validate disk exists and is a block device
if [[ ! -b "$DISK" ]]; then
    log_error "$DISK is not a valid block device!"
    echo "Available disks:"
    lsblk -d -o NAME,SIZE,MODEL,TYPE | grep disk
    exit 1
fi

# Check if disk is mounted
if mount | grep -q "$DISK"; then
    log_error "$DISK or its partitions are currently mounted!"
    echo "Mounted partitions:"
    mount | grep "$DISK"
    echo ""
    echo "Unmount them first: sudo umount ${DISK}*"
    exit 1
fi

# Detect partition naming scheme (nvme vs sata)
if [[ "$DISK" == *"nvme"* ]]; then
    PART_PREFIX="${DISK}p"
else
    PART_PREFIX="${DISK}"
fi

EFI_PART="${PART_PREFIX}1"
ROOT_PART="${PART_PREFIX}2"

# Check for existing partitions (FORCE guard)
if [[ -b "$EFI_PART" ]] || [[ -b "$ROOT_PART" ]]; then
    if [[ "${FORCE:-0}" != "1" ]]; then
        log_error "Partitions already exist on $DISK!"
        echo ""
        echo "  Found: $EFI_PART and/or $ROOT_PART"
        echo ""
        echo "  If you want to REFORMAT and ERASE these partitions, run:"
        echo "    FORCE=1 $0 $DISK $HOST"
        echo ""
        log_warn "This is a safety guard to prevent accidental data loss."
        exit 1
    else
        log_warn "FORCE=1 set - will reformat existing partitions!"
    fi
fi

# Run preflight checks BEFORE any destructive operations
preflight_checks

# Confirm with user
echo ""
echo "======================================"
echo "  NixOS Installation Configuration"
echo "======================================"
echo ""
echo "  Target disk:     $DISK"
echo "  EFI partition:   $EFI_PART ($EFI_SIZE)"
echo "  Root partition:  $ROOT_PART (LUKS encrypted)"
echo "  Host:            $HOST"
echo "  Flake path:      $SCRIPT_DIR"
echo ""
log_warn "THIS WILL ERASE ALL DATA ON $DISK!"
echo ""
read -p "Type 'yes' to continue: " confirm
if [[ "$confirm" != "yes" ]]; then
    log_error "Installation cancelled."
    exit 1
fi

# ====== STEP 1: Unmount and close existing LUKS ======
log_step "Step 1/8: Cleaning up existing mounts..."
umount -R /mnt 2>/dev/null || true
cryptsetup close "$MAPPER_NAME" 2>/dev/null || true

# ====== STEP 2: Partition the disk ======
log_step "Step 2/8: Partitioning $DISK..."
parted -s "$DISK" -- mklabel gpt
parted -s "$DISK" -- mkpart EFI fat32 1MiB "$EFI_SIZE"
parted -s "$DISK" -- mkpart cryptroot "$EFI_SIZE" 100%
parted -s "$DISK" -- set 1 esp on
log_ok "Partitioning complete"

# Wait for kernel to recognize partitions
sleep 2
partprobe "$DISK"
sleep 1

# ====== STEP 3: Setup LUKS encryption ======
log_step "Step 3/8: Setting up LUKS encryption on $ROOT_PART..."
echo ""
log_warn "You will be asked to create a disk encryption password."
log_warn "REMEMBER THIS PASSWORD - you'll need it on every boot!"
echo ""
cryptsetup luksFormat --type luks2 --cipher aes-xts-plain64 --key-size 512 \
    --hash sha256 --iter-time 2000 --pbkdf argon2id "$ROOT_PART"

log_info "Opening encrypted partition..."
cryptsetup open "$ROOT_PART" "$MAPPER_NAME"
log_ok "LUKS setup complete"

# ====== STEP 4: Format filesystems ======
log_step "Step 4/8: Formatting filesystems..."
mkfs.vfat -F 32 -n EFI "$EFI_PART"
mkfs.ext4 -L nixos "/dev/mapper/$MAPPER_NAME"
log_ok "Formatting complete"

# ====== STEP 5: Mount partitions ======
log_step "Step 5/8: Mounting partitions..."
mount "/dev/mapper/$MAPPER_NAME" /mnt
mkdir -p /mnt/boot
mount "$EFI_PART" /mnt/boot
log_ok "Mounting complete"

# ====== STEP 6: Generate hardware configuration ======
log_step "Step 6/8: Generating hardware configuration..."
nixos-generate-config --root /mnt --show-hardware-config > /tmp/hardware-config.nix

# Generated hardware config is at /tmp/hardware-config.nix
log_ok "Hardware configuration generated (/tmp/hardware-config.nix)"

# ====== COPY REPO TO TARGET ======
log_step "Copying repository to target: $TARGET_DIR"
rm -rf "$TARGET_DIR" || true
mkdir -p "$TARGET_DIR"
# Use cp -a to preserve attributes and include dotfiles
cp -a "$SRC_DIR"/. "$TARGET_DIR"/
log_ok "Repository copied to $TARGET_DIR (including dotfiles)"

# Ensure host directory exists in target and place generated hardware config there
mkdir -p "$TARGET_DIR/hosts/$HOST"
cp /tmp/hardware-config.nix "$TARGET_DIR/hosts/$HOST/hardware-configuration.nix"
log_ok "Hardware configuration copied to $TARGET_DIR/hosts/$HOST/hardware-configuration.nix"

# ====== STEP 7: Replace LUKS UUID placeholder ======
log_step "Step 7/8: Configuring LUKS UUID..."

# Get the UUID of the encrypted partition
LUKS_UUID=$(blkid -s UUID -o value "$ROOT_PART")
if [[ -z "$LUKS_UUID" ]]; then
    log_error "Failed to get UUID for $ROOT_PART"
    exit 1
fi
log_info "LUKS partition UUID: $LUKS_UUID"

# Replace placeholder in host default.nix (simple string replacement)
HOST_FILE="$TARGET_DIR/hosts/$HOST/default.nix"
if [[ ! -f "$HOST_FILE" ]]; then
    log_error "Host configuration missing: $HOST_FILE"
    exit 1
fi

# Verify placeholder exists before replacement
if ! grep -q "__LUKS_UUID_PLACEHOLDER__" "$HOST_FILE"; then
    log_error "LUKS UUID placeholder not found in $HOST_FILE"
    log_error "Expected: __LUKS_UUID_PLACEHOLDER__"
    exit 1
fi

# Replace placeholder with actual UUID
sed -i "s/__LUKS_UUID_PLACEHOLDER__/$LUKS_UUID/g" "$HOST_FILE"
log_ok "LUKS UUID configured in $HOST_FILE"

# Set evaluation directory to TARGET_DIR (contains UUID-substituted config)
EVAL_DIR="$TARGET_DIR"

# ====== STEP 8: Install NixOS ======
log_step "Step 8/8: Installing NixOS (this may take a while)..."
echo ""

# Build and install from TARGET_DIR which has the correct LUKS UUID
# WARNING: Do not run 'nix flake lock' here - if narHash mismatch occurs,
# user must fix flake.lock BEFORE running the installer
if [[ "${SKIP_BUILD_TEST:-0}" != "1" ]]; then
    log_info "Building NixOS configuration from $EVAL_DIR..."
    if ! nix build "$EVAL_DIR#nixosConfigurations.$HOST.config.system.build.toplevel" -L; then
        log_error "Build failed. Check flake.nix and try again."
        log_error "If narHash mismatch, fix flake.lock BEFORE running installer:"
        log_error "  cd $SRC_DIR && nix flake lock --refresh"
        exit 1
    fi
    log_ok "Build successful"
else
    log_warn "Skipping build test prior to install (SKIP_BUILD_TEST=1)"
fi

# Install from TARGET_DIR
nixos-install --flake "$EVAL_DIR#$HOST" --no-root-passwd

# ====== STEP 9: Set passwords ======
log_info "Setting user passwords..."
echo ""
log_warn "You will now set the root password:"
nixos-enter --root /mnt -c 'passwd root'

# Get username from EVAL_DIR/flake.nix (the copied tree)
FLAKE_USER=$(grep -oP 'username = "\K[^"]+' "$EVAL_DIR/flake.nix" | head -1)
if [[ -z "$FLAKE_USER" || "$FLAKE_USER" == "nixuser" ]]; then
    log_warn "Username is set to default 'nixuser' in flake.nix"
    read -p "Enter your desired username: " FLAKE_USER
    if [[ -z "$FLAKE_USER" ]]; then
        FLAKE_USER="nixuser"
    fi
    # Update flake.nix ONLY in EVAL_DIR (copied tree = TARGET_DIR)
    # Never touch the original source tree (SRC_DIR/SCRIPT_DIR)
    sed -i "s/username = \"nixuser\"/username = \"$FLAKE_USER\"/" "$EVAL_DIR/flake.nix"
    log_ok "Updated $EVAL_DIR/flake.nix with username: $FLAKE_USER"
    log_warn "NOTE: Run 'sudo nixos-rebuild switch --flake /etc/nixos#$HOST' after first boot to apply username change"
fi

echo ""
log_warn "Now set the password for $FLAKE_USER:"
nixos-enter --root /mnt -c "passwd $FLAKE_USER"

# ====== DONE ======
echo ""
echo "======================================"
echo "  Installation Complete!"
echo "======================================"
echo ""
log_ok "NixOS has been installed successfully!"
echo ""
echo "Next steps:"
echo "  1. Set root password:  nixos-enter --root /mnt -c 'passwd root'"
echo "  2. Set user password:  nixos-enter --root /mnt -c 'passwd $FLAKE_USER'"
echo "  3. Reboot:            reboot"
echo ""
echo "After reboot:"
echo "  - Enter your LUKS password at boot"
echo "  - Login as '$FLAKE_USER'"
echo "  - Hyprland will start automatically"
echo ""
echo "To rebuild after changes:"
echo "  cd /etc/nixos && sudo nixos-rebuild switch --flake .#$HOST"
echo ""
