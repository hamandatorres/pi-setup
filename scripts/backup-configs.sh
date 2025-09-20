#!/bin/bash
# scripts/backup-configs.sh
# Backup system and user configurations

set -e  # Exit on any error

# Get script directory and base directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BASE_DIR="$(dirname "$SCRIPT_DIR")"
LOG_FILE="$BASE_DIR/meta/backup-log.txt"

# Ensure directories exist
mkdir -p "$BASE_DIR/configs/etc"
mkdir -p "$BASE_DIR/configs/user"
mkdir -p "$BASE_DIR/configs/boot"
mkdir -p "$BASE_DIR/meta"

# Logging function
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

log "🔄 Starting configuration backup..."

# Backup system configs (with sudo for permissions)
log "⚙️ Backing up system configurations from /etc..."
if sudo rsync -av --exclude='*.log' --exclude='shadow*' --exclude='passwd*' /etc/ "$BASE_DIR/configs/etc/" >> "$LOG_FILE" 2>&1; then
    log "✅ System configs backed up successfully"
else
    log "❌ System config backup failed"
    exit 1
fi

# Backup user configs
log "👤 Backing up user configurations..."

# Backup .config directory if it exists
if [ -d "$HOME/.config" ]; then
    if rsync -av "$HOME/.config/" "$BASE_DIR/configs/user/.config/" >> "$LOG_FILE" 2>&1; then
        log "✅ User .config directory backed up"
    else
        log "⚠️ User .config backup had issues"
    fi
else
    log "⚠️ No .config directory found"
fi

# Backup shell configurations
for config_file in ".bashrc" ".zshrc" ".profile" ".bash_profile" ".bash_aliases"; do
    if [ -f "$HOME/$config_file" ]; then
        if cp "$HOME/$config_file" "$BASE_DIR/configs/user/$config_file" 2>> "$LOG_FILE"; then
            log "✅ Backed up $config_file"
        else
            log "⚠️ Failed to backup $config_file"
        fi
    fi
done

# Backup SSH directory if it exists
if [ -d "$HOME/.ssh" ]; then
    mkdir -p "$BASE_DIR/configs/user/.ssh"
    if rsync -av "$HOME/.ssh/" "$BASE_DIR/configs/user/.ssh/" >> "$LOG_FILE" 2>&1; then
        log "✅ SSH configuration backed up"
    else
        log "⚠️ SSH backup had issues"
    fi
else
    log "⚠️ No SSH directory found"
fi

# Backup boot configuration (Pi-specific)
if [ -f "/boot/config.txt" ]; then
    if sudo cp "/boot/config.txt" "$BASE_DIR/configs/boot/config.txt" 2>> "$LOG_FILE"; then
        log "✅ Boot configuration backed up"
    else
        log "⚠️ Boot config backup failed"
    fi
else
    log "⚠️ No /boot/config.txt found (not a Pi?)"
fi

# Backup other important configs
if [ -f "/boot/cmdline.txt" ]; then
    sudo cp "/boot/cmdline.txt" "$BASE_DIR/configs/boot/cmdline.txt" 2>> "$LOG_FILE" && log "✅ cmdline.txt backed up"
fi

log "🎉 Configuration backup complete!"
log "📁 System configs: $BASE_DIR/configs/etc/"
log "👤 User configs: $BASE_DIR/configs/user/"
log "🥾 Boot configs: $BASE_DIR/configs/boot/"
log "📝 Full log: $LOG_FILE"
