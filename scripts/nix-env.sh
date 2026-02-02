#!/usr/bin/env bash
# scripts/nix-env.sh
# Single source of truth for Nix configuration with flakes enabled
# Source this in other scripts: source "$(dirname "$0")/nix-env.sh"

set -euo pipefail

# Enable flakes and nix-command if not already set
# This allows the scripts to work in NixOS live/installer environments
export NIX_CONFIG="${NIX_CONFIG:-experimental-features = nix-command flakes}"

# Optional: verify nix is available
if ! command -v nix &>/dev/null; then
    echo "ERROR: nix command not found. Are you in a NixOS environment?"
    exit 1
fi
