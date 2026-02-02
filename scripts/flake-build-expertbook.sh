#!/usr/bin/env bash
# scripts/flake-build-expertbook.sh
# Build the expertbook host configuration

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(dirname "$SCRIPT_DIR")"

# Enable flakes
source "$SCRIPT_DIR/nix-env.sh"

echo "🔨 Building expertbook configuration..."
echo "   Repository: $REPO_DIR"
echo ""

if nix build "$REPO_DIR#nixosConfigurations.expertbook.config.system.build.toplevel" -L; then
    echo ""
    echo "✅ Build successful!"
    echo "   Result: ./result"
else
    echo ""
    echo "❌ Build failed. Review the errors above."
    exit 1
fi
