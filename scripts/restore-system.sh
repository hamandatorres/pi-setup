#!/bin/bash
# scripts/restore-system.sh
# Complete system restoration script for Raspberry Pi setup toolkit

set -e  # Exit on any error

# Get script directory and base directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BASE_DIR="$(dirname "$SCRIPT_DIR")"
LOG_FILE="$BASE_DIR/meta/restore-log.txt"

# Ensure meta directory exists
mkdir -p "$BASE_DIR/meta"

# Logging function
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

# Error handling
error_exit() {
    log "❌ ERROR: $1"
    exit 1
}

# Shell detection function
detect_shell() {
    case "$SHELL" in
        */bash) 
            log "🔍 Detected Bash shell"
            SHELL_CONFIG="$HOME/.bashrc"
            ;;
        */zsh) 
            log "🔍 Detected Zsh shell"
            SHELL_CONFIG="$HOME/.zshrc"
            ;;
        */fish) 
            log "🔍 Detected Fish shell"
            SHELL_CONFIG="$HOME/.config/fish/config.fish"
            ;;
        *) 
            log "🔍 Unknown shell: $SHELL, defaulting to bash"
            SHELL_CONFIG="$HOME/.bashrc"
            ;;
    esac
}

# Check if running as correct user
check_user() {
    if [ "$EUID" -eq 0 ]; then
        error_exit "Don't run this script as root. Use your regular user account."
    fi
    log "👤 Running as user: $(whoami)"
}

# System preparation
prepare_system() {
    log "🔧 Preparing system for restoration..."
    
    # Update package lists
    log "📦 Updating package lists..."
    sudo apt update || error_exit "Failed to update package lists"
    
    # Ensure rsync is installed (needed for config restoration)
    if ! command -v rsync &> /dev/null; then
        log "📦 Installing rsync..."
        sudo apt install -y rsync || error_exit "Failed to install rsync"
    fi
}

# Package restoration
restore_packages() {
    log "📦 Starting package restoration..."
    
    if [ -f "$BASE_DIR/packages/manual-packages.txt" ]; then
        log "📦 Installing manually installed packages..."
        # Filter out empty lines and comments
        grep -v '^#\|^$' "$BASE_DIR/packages/manual-packages.txt" | \
            xargs sudo apt install -y || log "⚠️ Some packages may have failed to install"
    else
        log "⚠️ Manual packages file not found, skipping package installation"
    fi
    
    # Install pip packages if file exists
    if [ -f "$BASE_DIR/packages/pip-packages.txt" ]; then
        log "🐍 Installing Python packages..."
        if command -v pip3 &> /dev/null; then
            pip3 install -r "$BASE_DIR/packages/pip-packages.txt" || log "⚠️ Some pip packages may have failed"
        else
            log "⚠️ pip3 not found, skipping Python package installation"
        fi
    fi
    
    # Install npm packages if file exists
    if [ -f "$BASE_DIR/packages/npm-packages.txt" ]; then
        log "📦 Installing Node.js packages..."
        if command -v npm &> /dev/null; then
            # Extract package names from npm list output and install globally
            grep -o '^[^@]*' "$BASE_DIR/packages/npm-packages.txt" | \
                while read -r package; do
                    [ -n "$package" ] && npm install -g "$package" 2>/dev/null || true
                done
        else
            log "⚠️ npm not found, skipping Node.js package installation"
        fi
    fi
}

# Configuration restoration
restore_configs() {
    log "⚙️ Starting configuration restoration..."
    
    # Backup existing configs
    BACKUP_DIR="$HOME/.config-backup-$(date +%Y%m%d-%H%M%S)"
    mkdir -p "$BACKUP_DIR"
    log "💾 Backing up existing configs to $BACKUP_DIR"
    
    # Restore system configs
    if [ -d "$BASE_DIR/configs/etc" ]; then
        log "⚙️ Restoring system configurations..."
        sudo rsync -av "$BASE_DIR/configs/etc/" /etc/ || log "⚠️ Some system configs may have failed to restore"
    else
        log "⚠️ System config directory not found, skipping"
    fi
    
    # Restore user configs
    if [ -d "$BASE_DIR/configs/user" ]; then
        log "⚙️ Restoring user configurations..."
        
        # Backup existing user configs if they exist
        [ -d "$HOME/.config" ] && cp -r "$HOME/.config" "$BACKUP_DIR/.config" 2>/dev/null || true
        [ -f "$HOME/.bashrc" ] && cp "$HOME/.bashrc" "$BACKUP_DIR/.bashrc" 2>/dev/null || true
        [ -f "$HOME/.zshrc" ] && cp "$HOME/.zshrc" "$BACKUP_DIR/.zshrc" 2>/dev/null || true
        
        # Restore configs
        rsync -av "$BASE_DIR/configs/user/" "$HOME/" || log "⚠️ Some user configs may have failed to restore"
    else
        log "⚠️ User config directory not found, skipping"
    fi
    
    # Restore boot configs if they exist
    if [ -f "$BASE_DIR/configs/boot/config.txt" ]; then
        log "⚙️ Restoring boot configuration..."
        sudo cp "$BASE_DIR/configs/boot/config.txt" /boot/config.txt || log "⚠️ Boot config restoration failed"
    fi
}

# Service restoration
restore_services() {
    log "🔄 Starting service restoration..."
    
    if [ -f "$SCRIPT_DIR/restore-services.sh" ]; then
        bash "$SCRIPT_DIR/restore-services.sh" || log "⚠️ Service restoration had issues"
    else
        log "⚠️ restore-services.sh not found, skipping service restoration"
    fi
    
    # Reload systemd daemon
    log "🔄 Reloading systemd daemon..."
    sudo systemctl daemon-reload || log "⚠️ Failed to reload systemd daemon"
}

# Cron job restoration
restore_cron() {
    if [ -f "$BASE_DIR/services/cron-jobs.txt" ]; then
        log "⏰ Restoring cron jobs..."
        crontab "$BASE_DIR/services/cron-jobs.txt" || log "⚠️ Cron job restoration failed"
    else
        log "⚠️ Cron jobs file not found, skipping"
    fi
}

# Post-restoration tasks
post_restore() {
    log "🔧 Running post-restoration tasks..."
    
    # Detect and set up shell
    detect_shell
    
    # Source shell config if it exists
    if [ -f "$SHELL_CONFIG" ]; then
        log "🐚 Shell config found: $SHELL_CONFIG"
        # Note: We can't source it in a script, but we inform the user
        log "💡 Remember to run: source $SHELL_CONFIG (or restart your terminal)"
    fi
    
    # Set proper permissions for restored files
    log "🔒 Setting proper permissions..."
    find "$HOME" -name ".ssh" -type d -exec chmod 700 {} \; 2>/dev/null || true
    find "$HOME/.ssh" -name "*" -type f -exec chmod 600 {} \; 2>/dev/null || true
    find "$HOME/.ssh" -name "*.pub" -type f -exec chmod 644 {} \; 2>/dev/null || true
}

# Validation
run_validation() {
    log "✅ Running validation..."
    
    if [ -f "$SCRIPT_DIR/validate-restore.sh" ]; then
        bash "$SCRIPT_DIR/validate-restore.sh"
    else
        log "⚠️ validate-restore.sh not found, skipping validation"
        log "💡 Consider creating a validation script for future use"
    fi
}

# Main execution
main() {
    log "🚀 Starting Raspberry Pi system restoration..."
    log "📍 Base directory: $BASE_DIR"
    log "📝 Log file: $LOG_FILE"
    
    # Pre-flight checks
    check_user
    
    # Show what we're about to do
    log "📋 Restoration plan:"
    [ -f "$BASE_DIR/packages/manual-packages.txt" ] && log "  ✓ Install $(wc -l < "$BASE_DIR/packages/manual-packages.txt") manual packages"
    [ -d "$BASE_DIR/configs/etc" ] && log "  ✓ Restore system configurations"
    [ -d "$BASE_DIR/configs/user" ] && log "  ✓ Restore user configurations"
    [ -f "$SCRIPT_DIR/restore-services.sh" ] && log "  ✓ Restore services"
    [ -f "$BASE_DIR/services/cron-jobs.txt" ] && log "  ✓ Restore cron jobs"
    
    # Ask for confirmation
    echo ""
    read -p "Continue with restoration? (y/N): " -n 1 -r
    echo ""
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        log "❌ Restoration cancelled by user"
        exit 1
    fi
    
    # Execute restoration steps
    prepare_system
    restore_packages
    restore_configs
    restore_services
    restore_cron
    post_restore
    run_validation
    
    log "🎉 System restoration complete!"
    log "📋 Summary:"
    log "  • Packages restored from snapshots"
    log "  • Configurations restored (backups in ~/.config-backup-*)"
    log "  • Services restored and reloaded"
    log "  • Cron jobs restored"
    log ""
    log "🔄 Next steps:"
    log "  • Restart your terminal or run: source $SHELL_CONFIG"
    log "  • Reboot if system configurations were changed"
    log "  • Check the validation results above"
    log ""
    log "📝 Full log saved to: $LOG_FILE"
}

# Run main function
main "$@"
