#!/bin/bash
# scripts/snapshot-pip-packages.sh
# Capture Python pip packages

set -e

# Get script directory and base directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BASE_DIR="$(dirname "$SCRIPT_DIR")"

# Ensure packages directory exists
mkdir -p "$BASE_DIR/packages"

echo "🐍 Capturing Python pip packages..."

# Check if pip3 is available
if command -v pip3 &> /dev/null; then
    # Get list of user-installed packages (not system packages)
    pip3 list --user --format=freeze > "$BASE_DIR/packages/pip-user-packages.txt" 2>/dev/null || echo "" > "$BASE_DIR/packages/pip-user-packages.txt"
    
    # Get all installed packages with versions
    pip3 list --format=freeze > "$BASE_DIR/packages/pip-all-packages.txt" 2>/dev/null || echo "" > "$BASE_DIR/packages/pip-all-packages.txt"
    
    # Count packages
    user_count=$(grep -c "^[^#]" "$BASE_DIR/packages/pip-user-packages.txt" 2>/dev/null || echo 0)
    all_count=$(grep -c "^[^#]" "$BASE_DIR/packages/pip-all-packages.txt" 2>/dev/null || echo 0)
    
    echo "✅ Captured $user_count user pip packages"
    echo "✅ Captured $all_count total pip packages"
    echo "📁 User packages: $BASE_DIR/packages/pip-user-packages.txt"
    echo "📁 All packages: $BASE_DIR/packages/pip-all-packages.txt"
else
    echo "⚠️ pip3 not found, skipping Python package capture"
    touch "$BASE_DIR/packages/pip-user-packages.txt"
    touch "$BASE_DIR/packages/pip-all-packages.txt"
fi

# Also capture pipx packages if available
if command -v pipx &> /dev/null; then
    echo "📦 Capturing pipx packages..."
    pipx list --short > "$BASE_DIR/packages/pipx-packages.txt" 2>/dev/null || echo "" > "$BASE_DIR/packages/pipx-packages.txt"
    pipx_count=$(grep -c "^[^#]" "$BASE_DIR/packages/pipx-packages.txt" 2>/dev/null || echo 0)
    echo "✅ Captured $pipx_count pipx packages"
else
    echo "⚠️ pipx not found, creating empty file"
    touch "$BASE_DIR/packages/pipx-packages.txt"
fi

echo "🎉 Python package capture complete!"