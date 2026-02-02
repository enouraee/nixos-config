#!/usr/bin/env bash
# scripts/flake-check.sh
# Run flake checks to validate configuration

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(dirname "$SCRIPT_DIR")"

# Enable flakes
source "$SCRIPT_DIR/nix-env.sh"

echo "🔍 Running flake checks..."
echo "   Repository: $REPO_DIR"
echo ""

if nix flake check "$REPO_DIR"; then
    echo ""
    echo "✅ All checks passed!"
else
    echo ""
    echo "❌ Checks failed. Review the errors above."
    exit 1
fi
