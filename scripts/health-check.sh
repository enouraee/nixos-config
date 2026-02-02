#!/usr/bin/env bash
#
# NixOS Health Check Script
# ==========================
# Run after install to verify system health.
# Usage: health-check
#
# Exit codes:
#   0 = all checks passed
#   1 = some checks failed
#   2 = script error

set -uo pipefail

# ====== COLORS ======
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
BOLD='\033[1m'
NC='\033[0m'

# ====== COUNTERS ======
PASS=0
FAIL=0
WARN=0
declare -a FAILURES=()
declare -a WARNINGS=()

# ====== HELPERS ======
check_pass() {
    echo -e "  ${GREEN}✅${NC} $1"
    ((PASS++))
}

check_fail() {
    echo -e "  ${RED}❌${NC} $1"
    ((FAIL++))
    FAILURES+=("$1: $2")
}

check_warn() {
    echo -e "  ${YELLOW}⚠️${NC} $1"
    ((WARN++))
    WARNINGS+=("$1: $2")
}

section() {
    echo ""
    echo -e "${BOLD}${BLUE}[$1]${NC}"
}

command_exists() {
    command -v "$1" &>/dev/null
}

service_active() {
    systemctl is-active --quiet "$1" 2>/dev/null
}

user_service_active() {
    systemctl --user is-active --quiet "$1" 2>/dev/null
}

# ====== START ======
echo ""
echo -e "${BOLD}╔══════════════════════════════════════╗${NC}"
echo -e "${BOLD}║     NixOS Health Check               ║${NC}"
echo -e "${BOLD}╚══════════════════════════════════════╝${NC}"
echo ""
echo "Running checks... ($(date '+%Y-%m-%d %H:%M:%S'))"

# ============================================================
# CORE SYSTEM
# ============================================================
section "Core System"

# NixOS version
if [[ -f /etc/os-release ]]; then
    source /etc/os-release
    check_pass "NixOS version: $VERSION ($VERSION_ID)"
else
    check_fail "NixOS version" "Cannot read /etc/os-release"
fi

# Hostname
HOSTNAME=$(hostname 2>/dev/null || cat /etc/hostname 2>/dev/null || echo "unknown")
if [[ -n "$HOSTNAME" && "$HOSTNAME" != "unknown" ]]; then
    check_pass "Hostname: $HOSTNAME"
else
    check_fail "Hostname" "Cannot determine hostname"
fi

# ============================================================
# NETWORK
# ============================================================
section "Network"

# Default route
if ip route | grep -q "^default"; then
    GATEWAY=$(ip route | grep "^default" | awk '{print $3}' | head -1)
    check_pass "Default route exists (gateway: $GATEWAY)"
else
    check_warn "No default route" "Network may be down or not configured"
fi

# DNS resolution
if command_exists host; then
    if timeout 5 host -W 3 nixos.org &>/dev/null; then
        check_pass "DNS resolution working"
    else
        check_warn "DNS resolution failed" "Check network/DNS config; may be offline"
    fi
elif command_exists nslookup; then
    if timeout 5 nslookup nixos.org &>/dev/null; then
        check_pass "DNS resolution working"
    else
        check_warn "DNS resolution failed" "Check network/DNS config; may be offline"
    fi
else
    check_warn "DNS tools not found" "Install bind-tools or dnsutils to test DNS"
fi

# NetworkManager
if service_active NetworkManager; then
    check_pass "NetworkManager running"
else
    check_warn "NetworkManager not running" "May be using different network manager"
fi

# ============================================================
# TIME & LOCALE
# ============================================================
section "Time & Locale"

# Timezone
TZ=$(timedatectl show --property=Timezone --value 2>/dev/null || cat /etc/timezone 2>/dev/null || echo "unknown")
if [[ "$TZ" == "Asia/Tehran" ]]; then
    check_pass "Timezone: $TZ"
elif [[ "$TZ" != "unknown" ]]; then
    check_warn "Timezone: $TZ" "Expected Asia/Tehran"
else
    check_fail "Timezone" "Cannot determine timezone"
fi

# Time sync
if timedatectl show --property=NTPSynchronized --value 2>/dev/null | grep -q "yes"; then
    check_pass "Time synchronized via NTP"
else
    check_warn "Time not NTP synchronized" "Run: timedatectl set-ntp true"
fi

# System time
SYSTIME=$(date '+%Y-%m-%d %H:%M:%S %Z')
check_pass "System time: $SYSTIME"

# ============================================================
# DISK & ENCRYPTION
# ============================================================
section "Disk & Encryption"

# Root mount
if mountpoint -q /; then
    ROOT_DEV=$(findmnt -n -o SOURCE /)
    ROOT_FS=$(findmnt -n -o FSTYPE /)
    check_pass "Root mounted: $ROOT_DEV ($ROOT_FS)"
else
    check_fail "Root not mounted" "Critical system error"
fi

# Boot mount
if mountpoint -q /boot; then
    BOOT_DEV=$(findmnt -n -o SOURCE /boot)
    check_pass "Boot mounted: $BOOT_DEV"
else
    check_fail "Boot not mounted" "/boot must be mounted for kernel updates"
fi

# LUKS encryption
if lsblk -o NAME,TYPE 2>/dev/null | grep -q "crypt"; then
    CRYPT_DEV=$(lsblk -o NAME,TYPE | grep crypt | awk '{print $1}' | head -1)
    check_pass "LUKS encryption active: $CRYPT_DEV"
elif [[ -e /dev/mapper/cryptroot ]]; then
    check_pass "LUKS encryption active: cryptroot"
else
    check_warn "No LUKS encryption detected" "Disk may be unencrypted"
fi

# udisks2 for automount
if service_active udisks2; then
    check_pass "udisks2 running (automount ready)"
else
    check_warn "udisks2 not running" "USB automount may not work"
fi

# Disk space
ROOT_USE=$(df / --output=pcent 2>/dev/null | tail -1 | tr -d ' %')
if [[ -n "$ROOT_USE" ]]; then
    if (( ROOT_USE < 80 )); then
        check_pass "Root disk usage: ${ROOT_USE}%"
    elif (( ROOT_USE < 95 )); then
        check_warn "Root disk usage: ${ROOT_USE}%" "Consider cleanup: sudo nix-collect-garbage -d"
    else
        check_fail "Root disk usage: ${ROOT_USE}%" "Critical! Run: sudo nix-collect-garbage -d"
    fi
fi

# ============================================================
# USER & SHELL
# ============================================================
section "User & Shell"

# Current user
CURRENT_USER=$(whoami)
check_pass "Logged in as: $CURRENT_USER"

# Default shell
USER_SHELL=$(getent passwd "$CURRENT_USER" | cut -d: -f7)
if [[ "$USER_SHELL" == *"zsh"* ]]; then
    check_pass "Default shell: zsh"
else
    check_warn "Default shell: $USER_SHELL" "Expected zsh"
fi

# Zsh running
if [[ -n "${ZSH_VERSION:-}" ]] || [[ "$SHELL" == *"zsh"* ]]; then
    check_pass "Running in zsh"
else
    check_pass "Running in: $SHELL (not zsh, but OK for health check)"
fi

# Oh-My-Zsh
if [[ -d "$HOME/.oh-my-zsh" ]] || [[ -d "${ZSH:-/nonexistent}" ]]; then
    check_pass "Oh-My-Zsh installed"
elif [[ -f "$HOME/.zshrc" ]] && grep -q "oh-my-zsh" "$HOME/.zshrc" 2>/dev/null; then
    check_pass "Oh-My-Zsh configured in .zshrc"
else
    check_warn "Oh-My-Zsh not detected" "May be managed by home-manager differently"
fi

# ============================================================
# DESKTOP / HYPRLAND
# ============================================================
section "Desktop / Hyprland"

# Check if in graphical session
if [[ -n "${WAYLAND_DISPLAY:-}" ]] || [[ -n "${DISPLAY:-}" ]]; then
    IN_GRAPHICAL=true
else
    IN_GRAPHICAL=false
fi

# Hyprland binary
if command_exists Hyprland || command_exists hyprland; then
    check_pass "Hyprland installed"
else
    check_fail "Hyprland not found" "Install via programs.hyprland.enable = true"
fi

# Hyprland running (if in session)
if [[ "$IN_GRAPHICAL" == true ]]; then
    if pgrep -x "Hyprland" &>/dev/null || [[ "${XDG_CURRENT_DESKTOP:-}" == "Hyprland" ]]; then
        check_pass "Hyprland session active"
    else
        check_warn "Hyprland not running" "Different compositor may be in use"
    fi
else
    check_warn "Not in graphical session" "Run this from Hyprland for full checks"
fi

# XDG Desktop Portal
if user_service_active xdg-desktop-portal; then
    check_pass "xdg-desktop-portal running"
elif service_active xdg-desktop-portal; then
    check_pass "xdg-desktop-portal running (system)"
else
    check_warn "xdg-desktop-portal not running" "File dialogs may not work"
fi

# Hyprland portal
if user_service_active xdg-desktop-portal-hyprland; then
    check_pass "xdg-desktop-portal-hyprland running"
elif pgrep -f "xdg-desktop-portal-hyprland" &>/dev/null; then
    check_pass "xdg-desktop-portal-hyprland running"
else
    if [[ "$IN_GRAPHICAL" == true ]]; then
        check_warn "Hyprland portal not running" "Screen sharing may not work"
    else
        check_pass "Hyprland portal (not in graphical session, skipped)"
    fi
fi

# D-Bus user session
if [[ -n "${DBUS_SESSION_BUS_ADDRESS:-}" ]]; then
    check_pass "D-Bus user session active"
else
    check_warn "D-Bus session not detected" "Some apps may not work correctly"
fi

# ============================================================
# AUDIO
# ============================================================
section "Audio"

# PipeWire
if user_service_active pipewire; then
    check_pass "PipeWire running"
elif pgrep -x "pipewire" &>/dev/null; then
    check_pass "PipeWire running (process)"
else
    check_fail "PipeWire not running" "Audio will not work"
fi

# WirePlumber
if user_service_active wireplumber; then
    check_pass "WirePlumber running"
elif pgrep -x "wireplumber" &>/dev/null; then
    check_pass "WirePlumber running (process)"
else
    check_warn "WirePlumber not running" "Audio routing may not work"
fi

# PipeWire-pulse
if user_service_active pipewire-pulse; then
    check_pass "PipeWire-pulse running"
elif pgrep -f "pipewire-pulse" &>/dev/null; then
    check_pass "PipeWire-pulse running (process)"
else
    check_warn "PipeWire-pulse not running" "PulseAudio apps may not work"
fi

# pactl test
if command_exists pactl; then
    if pactl info &>/dev/null; then
        AUDIO_SERVER=$(pactl info 2>/dev/null | grep "Server Name" | cut -d: -f2 | xargs)
        check_pass "Audio server: $AUDIO_SERVER"
    else
        check_warn "pactl info failed" "Audio server not responding"
    fi
else
    check_warn "pactl not installed" "Cannot verify audio server"
fi

# ============================================================
# INPUT / KEYBOARD
# ============================================================
section "Input / Keyboard"

# Check Hyprland keyboard config (if accessible)
if [[ -f "$HOME/.config/hypr/hyprland.conf" ]]; then
    if grep -q "kb_layout.*fa" "$HOME/.config/hypr/hyprland.conf" 2>/dev/null; then
        check_pass "Persian keyboard configured in Hyprland"
    else
        check_warn "Persian keyboard not in hyprland.conf" "Check modules/home/hyprland/settings.nix"
    fi
else
    # Check via hyprctl if available
    if command_exists hyprctl && [[ "$IN_GRAPHICAL" == true ]]; then
        if hyprctl devices 2>/dev/null | grep -qi "fa"; then
            check_pass "Persian keyboard layout active"
        else
            KB_LAYOUT=$(hyprctl devices 2>/dev/null | grep -A5 "Keyboard" | grep "keymap" | head -1 || echo "unknown")
            check_warn "Current keyboard: $KB_LAYOUT" "Persian (fa) not detected"
        fi
    else
        check_pass "Keyboard config (cannot verify outside Hyprland)"
    fi
fi

# X11 keyboard config
if command_exists setxkbmap; then
    XKB_LAYOUT=$(setxkbmap -query 2>/dev/null | grep layout | awk '{print $2}')
    if [[ "$XKB_LAYOUT" == *"fa"* ]] || [[ "$XKB_LAYOUT" == *"us,fa"* ]]; then
        check_pass "X11 keyboard layout: $XKB_LAYOUT (includes Persian)"
    elif [[ -n "$XKB_LAYOUT" ]]; then
        check_pass "X11 keyboard layout: $XKB_LAYOUT"
    fi
fi

# ============================================================
# SYSTEMD HEALTH
# ============================================================
section "Systemd Health"

# Failed units
FAILED_UNITS=$(systemctl --failed --no-legend 2>/dev/null | wc -l)
if (( FAILED_UNITS == 0 )); then
    check_pass "No failed systemd units"
else
    check_fail "$FAILED_UNITS failed systemd unit(s)" "Run: systemctl --failed"
    echo -e "  ${RED}Failed units:${NC}"
    systemctl --failed --no-legend 2>/dev/null | head -10 | while read -r line; do
        echo -e "    - $line"
    done
fi

# User failed units
FAILED_USER=$(systemctl --user --failed --no-legend 2>/dev/null | wc -l)
if (( FAILED_USER == 0 )); then
    check_pass "No failed user units"
else
    check_warn "$FAILED_USER failed user unit(s)" "Run: systemctl --user --failed"
fi

# ============================================================
# JOURNAL ERRORS
# ============================================================
section "Recent Errors (Boot Log)"

ERROR_COUNT=$(journalctl -b -p err..alert --no-pager -q 2>/dev/null | wc -l)
if (( ERROR_COUNT == 0 )); then
    check_pass "No errors in current boot log"
elif (( ERROR_COUNT < 10 )); then
    check_warn "$ERROR_COUNT error(s) in boot log" "Run: journalctl -b -p err"
else
    check_warn "$ERROR_COUNT error(s) in boot log" "Run: journalctl -b -p err | less"
fi

# Show top errors (truncated)
if (( ERROR_COUNT > 0 )); then
    echo -e "  ${YELLOW}Top errors (max 15):${NC}"
    journalctl -b -p err..alert --no-pager -q 2>/dev/null | head -15 | while read -r line; do
        # Truncate long lines
        echo "    ${line:0:100}"
    done
    if (( ERROR_COUNT > 15 )); then
        echo "    ... and $((ERROR_COUNT - 15)) more"
    fi
fi

# ============================================================
# SUMMARY
# ============================================================
echo ""
echo -e "${BOLD}══════════════════════════════════════${NC}"
echo -e "${BOLD}             SUMMARY                  ${NC}"
echo -e "${BOLD}══════════════════════════════════════${NC}"
echo ""

TOTAL=$((PASS + FAIL + WARN))
echo -e "  ${GREEN}✅ Passed:${NC}   $PASS"
echo -e "  ${RED}❌ Failed:${NC}   $FAIL"
echo -e "  ${YELLOW}⚠️  Warnings:${NC} $WARN"
echo -e "  ${BLUE}📊 Total:${NC}    $TOTAL checks"
echo ""

# Show failures with fixes
if (( FAIL > 0 )); then
    echo -e "${RED}${BOLD}FAILURES (need attention):${NC}"
    for failure in "${FAILURES[@]}"; do
        echo -e "  ${RED}•${NC} $failure"
    done
    echo ""
fi

# Show warnings
if (( WARN > 0 )); then
    echo -e "${YELLOW}${BOLD}WARNINGS (review recommended):${NC}"
    for warning in "${WARNINGS[@]}"; do
        echo -e "  ${YELLOW}•${NC} $warning"
    done
    echo ""
fi

# Final verdict
if (( FAIL == 0 )); then
    echo -e "${GREEN}${BOLD}🎉 System is healthy!${NC}"
    if (( WARN > 0 )); then
        echo -e "   (${WARN} warning(s) - review above)"
    fi
    exit 0
else
    echo -e "${RED}${BOLD}⚠️  System has issues that need attention.${NC}"
    echo ""
    echo "Suggested next steps:"
    echo "  1. Review failures above"
    echo "  2. Check: systemctl --failed"
    echo "  3. Check: journalctl -b -p err"
    echo "  4. Rebuild: sudo nixos-rebuild switch --flake /etc/nixos#\$(hostname)"
    exit 1
fi
