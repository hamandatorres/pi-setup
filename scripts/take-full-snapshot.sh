#!/bin/bash
# scripts/take-full-snapshot.sh
# Master script to capture complete system state

set -e

# Get script directory and base directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BASE_DIR="$(dirname "$SCRIPT_DIR")"
LOG_FILE="$BASE_DIR/meta/snapshot-log.txt"

# Ensure meta directory exists
mkdir -p "$BASE_DIR/meta"

# Logging function
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

# Clear previous log
> "$LOG_FILE"

log "🚀 Starting complete Raspberry Pi system snapshot..."
log "📍 Base directory: $BASE_DIR"
log "📝 Log file: $LOG_FILE"

# Make all scripts executable
chmod +x "$SCRIPT_DIR"/*.sh

echo ""
log "===================================================="
log "📦 STEP 1: System Packages"
log "===================================================="
if bash "$SCRIPT_DIR/snapshot-packages.sh"; then
    log "✅ System packages captured successfully"
else
    log "❌ System package capture failed"
    exit 1
fi

echo ""
log "===================================================="
log "🐍 STEP 2: Python Packages"
log "===================================================="
if bash "$SCRIPT_DIR/snapshot-pip-packages.sh"; then
    log "✅ Python packages captured successfully"
else
    log "❌ Python package capture failed"
    exit 1
fi

echo ""
log "===================================================="
log "📦 STEP 3: Node.js Packages"
log "===================================================="
if bash "$SCRIPT_DIR/snapshot-npm-packages.sh"; then
    log "✅ Node.js packages captured successfully"
else
    log "❌ Node.js package capture failed"
    exit 1
fi

echo ""
log "===================================================="
log "🔄 STEP 4: System Services"
log "===================================================="
if bash "$SCRIPT_DIR/snapshot-services.sh"; then
    log "✅ System services captured successfully"
else
    log "❌ System service capture failed"
    exit 1
fi

echo ""
log "===================================================="
log "⏰ STEP 5: Cron Jobs"
log "===================================================="
if bash "$SCRIPT_DIR/snapshot-cron.sh"; then
    log "✅ Cron jobs captured successfully"
else
    log "❌ Cron job capture failed"
    exit 1
fi

echo ""
log "===================================================="
log "⚙️ STEP 6: Configuration Files"
log "===================================================="
if bash "$SCRIPT_DIR/backup-configs.sh"; then
    log "✅ Configuration files backed up successfully"
else
    log "❌ Configuration backup failed"
    exit 1
fi

echo ""
log "===================================================="
log "📊 SNAPSHOT SUMMARY"
log "===================================================="

# Count what we captured
manual_packages=$(grep -c "^[^#]" "$BASE_DIR/packages/manual-packages.txt" 2>/dev/null || echo 0)
all_packages=$(grep -c "^[^#]" "$BASE_DIR/packages/all-packages.txt" 2>/dev/null || echo 0)
pip_packages=$(grep -c "^[^#]" "$BASE_DIR/packages/pip-all-packages.txt" 2>/dev/null || echo 0)
npm_packages=$(grep -c "^[^#]" "$BASE_DIR/packages/npm-package-names.txt" 2>/dev/null || echo 0)
services=$(grep -c "^[^#]" "$BASE_DIR/services/enabled-services.txt" 2>/dev/null || echo 0)
cron_jobs=$(grep -c "^[^#]" "$BASE_DIR/services/cron-jobs.txt" 2>/dev/null || echo 0)

log "📦 Manual APT packages: $manual_packages"
log "📦 Total APT packages: $all_packages"
log "🐍 Python packages: $pip_packages"
log "📦 Node.js packages: $npm_packages"
log "🔄 Enabled services: $services"
log "⏰ Cron jobs: $cron_jobs"
log "⚙️ Configuration files: ✅ Captured"

# Check if configs directory has content
if [ -d "$BASE_DIR/configs/etc" ] && [ "$(ls -A "$BASE_DIR/configs/etc" 2>/dev/null)" ]; then
    log "📁 System configs: ✅ Present"
else
    log "📁 System configs: ❌ Missing"
fi

if [ -d "$BASE_DIR/configs/user" ] && [ "$(ls -A "$BASE_DIR/configs/user" 2>/dev/null)" ]; then
    log "👤 User configs: ✅ Present"
else
    log "👤 User configs: ❌ Missing"
fi

if [ -d "$BASE_DIR/configs/boot" ] && [ "$(ls -A "$BASE_DIR/configs/boot" 2>/dev/null)" ]; then
    log "🥾 Boot configs: ✅ Present"
else
    log "🥾 Boot configs: ❌ Missing"
fi

echo ""
log "🎉 COMPLETE SYSTEM SNAPSHOT FINISHED!"
log "======================================"
log "📅 Snapshot taken on: $(date)"
log "💻 Hostname: $(hostname)"
log "👤 User: $(whoami)"
log "🐧 OS: $(lsb_release -d 2>/dev/null | cut -f2 || uname -a)"

# Calculate total size
total_size=$(du -sh "$BASE_DIR" 2>/dev/null | cut -f1 || echo "Unknown")
log "💾 Total backup size: $total_size"

log ""
log "📋 To restore this system on another machine:"
log "  1. Copy this entire directory to the target system"
log "  2. Run: cd scripts && ./restore-system.sh"
log "  3. Run: ./validate-restore.sh"
log ""
log "📝 Full snapshot log: $LOG_FILE"

echo ""
echo "🚀 Snapshot complete! Your Pi state is now fully captured."
echo "💾 Run './restore-system.sh' on any Pi to recreate this setup."