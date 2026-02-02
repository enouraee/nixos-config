#!/usr/bin/env bash
# scripts/flake-lock-refresh.sh
# Refresh flake.lock without changing input versions (fixes narHash mismatches)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(dirname "$SCRIPT_DIR")"

# Enable flakes
source "$SCRIPT_DIR/nix-env.sh"

echo "🔄 Refreshing flake.lock..."
echo "   Repository: $REPO_DIR"
echo ""
echo "This will re-fetch inputs at their current locked versions."
echo "Use this to fix 'narHash mismatch' errors."
echo ""

cd "$REPO_DIR"

if nix flake lock --refresh; then
    echo ""
    echo "✅ flake.lock refreshed successfully!"
    echo ""
    echo "The lock file has been updated with fresh hashes."
    echo "Commit the changes: git add flake.lock && git commit -m 'chore: refresh flake.lock'"
else
    echo ""
    echo "❌ Lock refresh failed. Review the errors above."
    exit 1
fi
