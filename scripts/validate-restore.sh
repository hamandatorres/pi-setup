#!/bin/bash
# scripts/validate-restore.sh
# Validation script for Raspberry Pi system restoration

set -e

# Get script directory and base directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BASE_DIR="$(dirname "$SCRIPT_DIR")"
LOG_FILE="$BASE_DIR/meta/validation-log.txt"
FAILED=0
WARNINGS=0
PASSED=0

# Ensure meta directory exists
mkdir -p "$BASE_DIR/meta"

# Clear previous validation log
> "$LOG_FILE"

# Logging and validation functions
log() {
    echo "$1" | tee -a "$LOG_FILE"
}

validate_success() {
    log "✅ $1"
    ((PASSED++))
}

validate_failure() {
    log "❌ $1"
    ((FAILED++))
}

validate_warning() {
    log "⚠️ $1"
    ((WARNINGS++))
}

# Generic validation function
validate() {
    local test_command="$1"
    local success_message="$2"
    local failure_message="$3"
    
    if eval "$test_command" &>/dev/null; then
        validate_success "$success_message"
        return 0
    else
        validate_failure "$failure_message"
        return 1
    fi
}

# Package validation
validate_packages() {
    log ""
    log "📦 Validating Package Installation..."
    log "=================================="
    
    if [ ! -f "$BASE_DIR/packages/manual-packages.txt" ]; then
        validate_warning "Manual packages file not found, skipping package validation"
        return
    fi
    
    # Get installed packages once (much faster)
    local installed_packages_file="/tmp/installed_packages_$.txt"
    dpkg -l | awk '/^ii/ {print $2}' > "$installed_packages_file"
    
    local total_packages=0
    local failed_packages=0
    
    log "📦 Checking packages (this may take a moment)..."
    
    while read -r package <&3; do
        # Skip empty lines and comments
        [[ -z "$package" || "$package" =~ ^#.*$ ]] && continue
        
        ((total_packages++))
        
        # Show progress every 50 packages
        if (( total_packages % 50 == 0 )); then
            log "📦 Checked $total_packages packages so far..."
        fi
        
        if grep -q "^$package$" "$installed_packages_file"; then
            # Only log failures and every 50th success to avoid spam
            if (( total_packages % 50 == 0 )); then
                validate_success "Package '$package' is installed (and $((50 - failed_packages % 50)) others)"
            fi
        else
            validate_failure "Package '$package' is NOT installed"
            ((failed_packages++))
        fi
    done 3< "$BASE_DIR/packages/manual-packages.txt"
    
    # Clean up temp file
    rm -f "$installed_packages_file"
    
    if [ $failed_packages -eq 0 ]; then
        log "📦 All $total_packages packages installed successfully!"
        validate_success "All $total_packages packages are installed"
    else
        log "📦 $failed_packages out of $total_packages packages failed to install"
        validate_failure "$failed_packages packages missing out of $total_packages total"
    fi
}

# Service validation
validate_services() {
    log ""
    log "🔄 Validating Services..."
    log "========================"
    
    if [ ! -f "$BASE_DIR/services/enabled-services.txt" ]; then
        validate_warning "Enabled services file not found, skipping service validation"
        return
    fi
    
    local total_services=0
    local failed_services=0
    
    # Read services into an array first
    local services=()
    while IFS= read -r line; do
        [ -z "$line" ] && continue
        # Extract service name (first column)
        local service_name=$(echo "$line" | awk '{print $1}')
        # Skip if not a proper service name
        [[ ! "$service_name" =~ \.service$ ]] && continue
        services+=("$service_name")
    done < "$BASE_DIR/services/enabled-services.txt"
    
    # Now check each service
    for service_name in "${services[@]}"; do
        ((total_services++))
        
        # Check if service exists
        if ! systemctl list-unit-files 2>/dev/null | grep -q "$service_name"; then
            validate_warning "Service '$service_name' does not exist on this system"
            continue
        fi
        
        # Check if service is enabled
        if systemctl is-enabled "$service_name" &>/dev/null; then
            validate_success "Service '$service_name' is enabled"
            
            # Check if service is active
            if systemctl is-active "$service_name" &>/dev/null; then
                validate_success "Service '$service_name' is running"
            else
                validate_failure "Service '$service_name' is enabled but NOT running"
                ((failed_services++))
            fi
        else
            validate_failure "Service '$service_name' is NOT enabled"
            ((failed_services++))
        fi
    done
    
    if [ $failed_services -eq 0 ]; then
        log "🔄 All $total_services services are properly configured!"
    else
        log "🔄 $failed_services out of $total_services services have issues"
    fi
}

# Configuration validation
validate_configs() {
    log ""
    log "⚙️ Validating Configurations..."
    log "=============================="
    
    # Check common user config files
    validate "[ -f \"$HOME/.bashrc\" ]" \
        "User .bashrc exists" \
        "User .bashrc is missing"
    
    validate "[ -f \"$HOME/.profile\" ]" \
        "User .profile exists" \
        "User .profile is missing"
    
    # Check if .config directory exists
    validate "[ -d \"$HOME/.config\" ]" \
        "User .config directory exists" \
        "User .config directory is missing"
    
    # Check SSH configuration if it exists
    if [ -d "$HOME/.ssh" ]; then
        validate_success "SSH directory exists"
        
        # Check SSH directory permissions
        local ssh_perms=$(stat -c %a "$HOME/.ssh" 2>/dev/null || echo "000")
        if [ "$ssh_perms" = "700" ]; then
            validate_success "SSH directory has correct permissions (700)"
        else
            validate_failure "SSH directory has incorrect permissions ($ssh_perms, should be 700)"
        fi
        
        # Check for SSH keys and their permissions
        for key_file in "$HOME/.ssh/id_rsa" "$HOME/.ssh/id_ed25519" "$HOME/.ssh/id_ecdsa"; do
            if [ -f "$key_file" ]; then
                local key_perms=$(stat -c %a "$key_file" 2>/dev/null || echo "000")
                if [ "$key_perms" = "600" ]; then
                    validate_success "SSH private key $(basename "$key_file") has correct permissions"
                else
                    validate_failure "SSH private key $(basename "$key_file") has incorrect permissions ($key_perms, should be 600)"
                fi
            fi
        done
        
        for pub_key in "$HOME/.ssh"/*.pub; do
            if [ -f "$pub_key" ]; then
                local pub_perms=$(stat -c %a "$pub_key" 2>/dev/null || echo "000")
                if [ "$pub_perms" = "644" ]; then
                    validate_success "SSH public key $(basename "$pub_key") has correct permissions"
                else
                    validate_failure "SSH public key $(basename "$pub_key") has incorrect permissions ($pub_perms, should be 644)"
                fi
            fi
        done
    else
        validate_warning "No SSH directory found"
    fi
    
    # Check system configs if they were restored
    if [ -d "$BASE_DIR/configs/etc" ]; then
        validate_success "System config backup directory exists"
        
        # Check a few critical system files
        validate "[ -f \"/etc/hostname\" ]" \
            "System hostname file exists" \
            "System hostname file is missing"
            
        validate "[ -f \"/etc/hosts\" ]" \
            "System hosts file exists" \
            "System hosts file is missing"
    fi
}

# Network validation
validate_network() {
    log ""
    log "🌐 Validating Network..."
    log "======================="
    
    # Check network connectivity
    if ping -c 1 8.8.8.8 &>/dev/null; then
        validate_success "Internet connectivity working"
    else
        validate_failure "No internet connectivity"
    fi
    
    # Check if WiFi is connected (if applicable)
    if command -v iwgetid &>/dev/null; then
        local wifi_ssid=$(iwgetid -r 2>/dev/null)
        if [ -n "$wifi_ssid" ]; then
            validate_success "WiFi connected to '$wifi_ssid'"
        else
            validate_warning "WiFi not connected (may be using ethernet)"
        fi
    fi
    
    # Check SSH service
    if systemctl is-active ssh &>/dev/null; then
        validate_success "SSH service is running"
    else
        validate_failure "SSH service is not running"
    fi
}

# Python environment validation
validate_python() {
    log ""
    log "🐍 Validating Python Environment..."
    log "=================================="
    
    if command -v python3 &>/dev/null; then
        local python_version=$(python3 --version)
        validate_success "Python3 available: $python_version"
        
        if command -v pip3 &>/dev/null; then
            validate_success "pip3 is available"
            
            # Check if pip packages were restored
            if [ -f "$BASE_DIR/packages/pip-packages.txt" ]; then
                local total_pip=0
                local failed_pip=0
                
                while read -r line <&5; do
                    # Skip empty lines and extract package name
                    [ -z "$line" ] && continue
                    local package=$(echo "$line" | cut -d'=' -f1 | cut -d'>' -f1 | cut -d'<' -f1)
                    [ -z "$package" ] && continue
                    
                    ((total_pip++))
                    
                    if pip3 show "$package" &>/dev/null; then
                        validate_success "Python package '$package' is installed"
                    else
                        validate_failure "Python package '$package' is NOT installed"
                        ((failed_pip++))
                    fi
                done 5< "$BASE_DIR/packages/pip-packages.txt"
                
                if [ $failed_pip -eq 0 ] && [ $total_pip -gt 0 ]; then
                    log "🐍 All $total_pip Python packages installed successfully!"
                elif [ $total_pip -gt 0 ]; then
                    log "🐍 $failed_pip out of $total_pip Python packages failed to install"
                fi
            else
                validate_warning "No pip packages file found for validation"
            fi
        else
            validate_failure "pip3 is not available"
        fi
    else
        validate_failure "Python3 is not available"
    fi
}

# System health validation
validate_system_health() {
    log ""
    log "🏥 Validating System Health..."
    log "============================="
    
    # Check disk space
    local root_usage=$(df / | awk 'NR==2 {print $5}' | sed 's/%//')
    if [ "$root_usage" -lt 90 ]; then
        validate_success "Root filesystem usage: $root_usage% (healthy)"
    elif [ "$root_usage" -lt 95 ]; then
        validate_warning "Root filesystem usage: $root_usage% (getting full)"
    else
        validate_failure "Root filesystem usage: $root_usage% (critically full)"
    fi
    
    # Check memory
    local mem_available=$(free | awk 'NR==2{printf "%.0f", $7/$2*100}')
    if [ "$mem_available" -gt 10 ]; then
        validate_success "Available memory: $mem_available% (healthy)"
    else
        validate_warning "Available memory: $mem_available% (low)"
    fi
    
    # Check system load
    local load_avg=$(uptime | awk -F'load average:' '{print $2}' | cut -d',' -f1 | xargs)
    validate_success "System load average: $load_avg"
    
    # Check if system needs reboot
    if [ -f /var/run/reboot-required ]; then
        validate_warning "System reboot is required"
    else
        validate_success "No reboot required"
    fi
}

# Cron validation
validate_cron() {
    log ""
    log "⏰ Validating Cron Jobs..."
    log "========================="
    
    if [ -f "$BASE_DIR/services/cron-jobs.txt" ]; then
        if crontab -l &>/dev/null; then
            local current_cron_count=$(crontab -l 2>/dev/null | grep -v '^#' | grep -v '^$' | wc -l)
            local expected_cron_count=$(grep -v '^#' "$BASE_DIR/services/cron-jobs.txt" | grep -v '^$' | wc -l)
            
            if [ "$current_cron_count" -eq "$expected_cron_count" ]; then
                validate_success "Cron jobs restored ($current_cron_count jobs)"
            else
                validate_warning "Cron job count mismatch (current: $current_cron_count, expected: $expected_cron_count)"
            fi
        else
            validate_failure "No cron jobs found (but cron-jobs.txt exists)"
        fi
    else
        validate_warning "No cron jobs file found for validation"
    fi
}

# Main validation function
main() {
    log "🔍 Starting System Restoration Validation"
    log "========================================"
    log "🕒 Validation started at: $(date)"
    log "📍 Validating restoration in: $BASE_DIR"
    log ""
    
    # Run all validation checks
    validate_packages
    validate_services
    validate_configs
    validate_network
    validate_python
    validate_system_health
    validate_cron
    
    # Summary
    log ""
    log "📊 Validation Summary"
    log "===================="
    log "✅ Passed: $PASSED"
    log "❌ Failed: $FAILED"
    log "⚠️ Warnings: $WARNINGS"
    log ""
    
    if [ $FAILED -eq 0 ]; then
        if [ $WARNINGS -eq 0 ]; then
            log "🎉 Perfect! All validations passed with no warnings."
            log "🚀 Your Pi restoration is complete and fully functional!"
        else
            log "✅ Good! All critical validations passed, but there are $WARNINGS warnings to review."
            log "💡 Check the warnings above - they may not be critical issues."
        fi
        exit 0
    else
        log "⚠️ Validation completed with $FAILED failures."
        log "🔧 Please review the failed items above and fix them before considering the restoration complete."
        log ""
        log "💡 Common fixes:"
        log "  • Run 'sudo apt update && sudo apt upgrade' for package issues"
        log "  • Run 'sudo systemctl start <service-name>' for service issues"
        log "  • Check file permissions with 'ls -la' for config issues"
        log "  • Reboot the system if services aren't starting properly"
        exit 1
    fi
}

# Run main function
main "$@"
