#!/bin/bash
# scripts/snapshot-npm-packages.sh
# Capture Node.js npm packages

set -e

# Get script directory and base directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BASE_DIR="$(dirname "$SCRIPT_DIR")"

# Ensure packages directory exists
mkdir -p "$BASE_DIR/packages"

echo "📦 Capturing Node.js npm packages..."

# Check if npm is available
if command -v npm &> /dev/null; then
    # Get globally installed packages
    npm list -g --depth=0 --parseable --silent > "$BASE_DIR/packages/npm-global-packages.txt" 2>/dev/null || echo "" > "$BASE_DIR/packages/npm-global-packages.txt"
    
    # Extract just package names and versions in a cleaner format
    npm list -g --depth=0 --json --silent 2>/dev/null | \
        jq -r '.dependencies | keys[]' 2>/dev/null > "$BASE_DIR/packages/npm-package-names.txt" || \
        npm list -g --depth=0 --parseable --silent 2>/dev/null | \
        grep -v "^/.*node_modules$" | \
        sed 's|.*/node_modules/||' > "$BASE_DIR/packages/npm-package-names.txt"
    
    # Count packages
    global_count=$(grep -c "." "$BASE_DIR/packages/npm-package-names.txt" 2>/dev/null || echo 0)
    
    echo "✅ Captured $global_count global npm packages"
    echo "📁 Package names: $BASE_DIR/packages/npm-package-names.txt"
    echo "📁 Full paths: $BASE_DIR/packages/npm-global-packages.txt"
else
    echo "⚠️ npm not found, skipping Node.js package capture"
    touch "$BASE_DIR/packages/npm-global-packages.txt"
    touch "$BASE_DIR/packages/npm-package-names.txt"
fi

# Also check for yarn if available
if command -v yarn &> /dev/null; then
    echo "🧶 Capturing yarn global packages..."
    yarn global list --depth=0 > "$BASE_DIR/packages/yarn-global-packages.txt" 2>/dev/null || echo "" > "$BASE_DIR/packages/yarn-global-packages.txt"
    echo "✅ Yarn packages captured"
else
    echo "⚠️ yarn not found, creating empty file"
    touch "$BASE_DIR/packages/yarn-global-packages.txt"
fi

echo "🎉 Node.js package capture complete!"