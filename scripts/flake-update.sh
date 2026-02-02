#!/usr/bin/env bash
# scripts/flake-update.sh
# Update all flake inputs to their latest versions

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(dirname "$SCRIPT_DIR")"

# Enable flakes
source "$SCRIPT_DIR/nix-env.sh"

echo "⬆️  Updating flake inputs..."
echo "   Repository: $REPO_DIR"
echo ""
echo "This will update nixpkgs, home-manager, and all other inputs"
echo "to their latest versions."
echo ""

cd "$REPO_DIR"

if nix flake update; then
    echo ""
    echo "✅ Flake inputs updated successfully!"
    echo ""
    echo "Review changes:"
    echo "  git diff flake.lock"
    echo ""
    echo "Test the new configuration:"
    echo "  nix flake check"
    echo "  ./scripts/flake-build-expertbook.sh"
    echo ""
    echo "Commit if satisfied:"
    echo "  git add flake.lock && git commit -m 'chore: update flake inputs'"
else
    echo ""
    echo "❌ Update failed. Review the errors above."
    exit 1
fi
