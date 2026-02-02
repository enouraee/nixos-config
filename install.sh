#!/usr/bin/env bash
#
# NixOS Installation Script with LUKS Encryption
# ================================================
# This script will:
#   1. Partition the disk (GPT: EFI + encrypted root)
#   2. Setup LUKS encryption on root partition
#   3. Format filesystems (FAT32 for EFI, ext4 for root)
#   4. Mount partitions
#   5. Generate hardware configuration
#   6. Install NixOS with this flake
#
# Usage:
#   sudo ./install.sh /dev/sdX        # Replace sdX with your target disk
#   sudo ./install.sh /dev/nvme0n1    # For NVMe drives
#
# WARNING: This will ERASE ALL DATA on the target disk!

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
HOST="expertbook"                    # Change if using different host
EFI_SIZE="512M"                      # EFI partition size
MAPPER_NAME="cryptroot"              # LUKS mapper name

log_info()  { echo -e "${BLUE}[INFO]${NC} $1"; }
log_ok()    { echo -e "${GREEN}[OK]${NC} $1"; }
log_warn()  { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

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
echo ""
log_warn "THIS WILL ERASE ALL DATA ON $DISK!"
echo ""
read -p "Type 'yes' to continue: " confirm
if [[ "$confirm" != "yes" ]]; then
    log_error "Installation cancelled."
    exit 1
fi

# ====== STEP 1: Unmount and close existing LUKS ======
log_info "Cleaning up existing mounts..."
umount -R /mnt 2>/dev/null || true
cryptsetup close "$MAPPER_NAME" 2>/dev/null || true

# ====== STEP 2: Partition the disk ======
log_info "Partitioning $DISK..."
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
log_info "Setting up LUKS encryption on $ROOT_PART..."
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
log_info "Formatting filesystems..."
mkfs.vfat -F 32 -n EFI "$EFI_PART"
mkfs.ext4 -L nixos "/dev/mapper/$MAPPER_NAME"
log_ok "Formatting complete"

# ====== STEP 5: Mount partitions ======
log_info "Mounting partitions..."
mount "/dev/mapper/$MAPPER_NAME" /mnt
mkdir -p /mnt/boot
mount "$EFI_PART" /mnt/boot
log_ok "Mounting complete"

# ====== STEP 6: Generate hardware configuration ======
log_info "Generating hardware configuration..."
nixos-generate-config --root /mnt --show-hardware-config > /tmp/hardware-config.nix

# Get the script's directory (where the flake is)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Copy generated hardware config
cp /tmp/hardware-config.nix "$SCRIPT_DIR/hosts/$HOST/hardware-configuration.nix"
log_ok "Hardware configuration generated"

# Update hardware config with correct LUKS device
log_info "Updating LUKS configuration in hardware-configuration.nix..."

# Get the UUID of the encrypted partition
LUKS_UUID=$(blkid -s UUID -o value "$ROOT_PART")

# Patch the hardware configuration
cat >> "$SCRIPT_DIR/hosts/$HOST/hardware-configuration.nix" << EOF

  # LUKS encryption (auto-configured by install.sh)
  boot.initrd.luks.devices."$MAPPER_NAME" = {
    device = "/dev/disk/by-uuid/$LUKS_UUID";
    preLVM = true;
    allowDiscards = true;
  };
EOF

log_ok "LUKS configuration added"

# ====== STEP 7: Clone config to target ======
log_info "Copying configuration to /mnt..."
mkdir -p /mnt/etc/nixos
cp -r "$SCRIPT_DIR"/* /mnt/etc/nixos/
log_ok "Configuration copied"

# ====== STEP 8: Install NixOS ======
log_info "Installing NixOS (this may take a while)..."
echo ""
nixos-install --flake "/mnt/etc/nixos#$HOST" --no-root-passwd

# ====== STEP 9: Set passwords ======
log_info "Setting user passwords..."
echo ""
log_warn "You will now set the root password:"
nixos-enter --root /mnt -c 'passwd root'

# Get username from flake.nix
FLAKE_USER=$(grep -oP 'username = "\K[^"]+' "$SCRIPT_DIR/flake.nix" | head -1)
if [[ -z "$FLAKE_USER" || "$FLAKE_USER" == "nixuser" ]]; then
    log_warn "Username is set to default 'nixuser' in flake.nix"
    read -p "Enter your desired username: " FLAKE_USER
    if [[ -z "$FLAKE_USER" ]]; then
        FLAKE_USER="nixuser"
    fi
    # Update flake.nix with the new username
    sed -i "s/username = \"nixuser\"/username = \"$FLAKE_USER\"/" "$SCRIPT_DIR/flake.nix"
    log_ok "Updated flake.nix with username: $FLAKE_USER"
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
