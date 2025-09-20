#!/bin/bash
# scripts/snapshot-packages.sh
# Capture system packages

set -e

# Get script directory and base directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BASE_DIR="$(dirname "$SCRIPT_DIR")"

# Ensure packages directory exists
mkdir -p "$BASE_DIR/packages"

echo "📦 Capturing system packages..."

# Get manually installed packages
echo "📦 Capturing manually installed packages..."
apt-mark showmanual > "$BASE_DIR/packages/manual-packages.txt"
manual_count=$(wc -l < "$BASE_DIR/packages/manual-packages.txt")
echo "✅ Captured $manual_count manually installed packages"

# Get all packages with their status
echo "📦 Capturing all package selections..."
dpkg --get-selections > "$BASE_DIR/packages/all-packages.txt"
all_count=$(wc -l < "$BASE_DIR/packages/all-packages.txt")
echo "✅ Captured $all_count total packages"

# Get apt repositories
echo "📦 Capturing apt sources..."
if [ -d "/etc/apt/sources.list.d" ]; then
    mkdir -p "$BASE_DIR/packages/apt-sources"
    sudo cp /etc/apt/sources.list "$BASE_DIR/packages/apt-sources/" 2>/dev/null || echo "# No sources.list found" > "$BASE_DIR/packages/apt-sources/sources.list"
    sudo cp -r /etc/apt/sources.list.d/* "$BASE_DIR/packages/apt-sources/" 2>/dev/null || true
    sources_count=$(ls "$BASE_DIR/packages/apt-sources/" | wc -l)
    echo "✅ Captured $sources_count apt source files"
fi

# Get package holds
echo "📦 Capturing package holds..."
apt-mark showhold > "$BASE_DIR/packages/held-packages.txt" 2>/dev/null || echo "" > "$BASE_DIR/packages/held-packages.txt"
hold_count=$(grep -c "^[^#]" "$BASE_DIR/packages/held-packages.txt" 2>/dev/null || echo 0)
echo "✅ Captured $hold_count held packages"

echo "📁 Manual packages: $BASE_DIR/packages/manual-packages.txt"
echo "📁 All packages: $BASE_DIR/packages/all-packages.txt"
echo "📁 APT sources: $BASE_DIR/packages/apt-sources/"
echo "📁 Held packages: $BASE_DIR/packages/held-packages.txt"
echo "🎉 Package capture complete!"
