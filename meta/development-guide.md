# 🧰 Raspberry Pi Self-Healing Setup Toolkit - Development Guide

## 📋 Current State Analysis

Your foundation is solid! Here's what you have working:

### ✅ Strengths
- **Package Management**: Capturing both manual and all packages
- **Service Management**: Tracking enabled services with good error handling
- **Config Backup**: Basic rsync approach for system and user configs
- **Modular Design**: Clean separation of concerns across directories
- **Logging**: Service restoration includes proper logging

### 🔧 Current Issues to Address
1. `restore-system.sh` is incomplete (shell detection doesn't lead anywhere)
2. `services/` directory purpose needs clarification
3. No validation that restoration worked
4. Missing critical system components (see enhancement list below)

## 🗂️ Recommended Directory Structure

```
pi-setup/
├── configs/
│   ├── etc/           # System configs (/etc backup)
│   ├── user/          # User configs (~/.config, dotfiles)
│   └── boot/          # Boot configs (/boot/config.txt, etc.)
├── packages/
│   ├── manual-packages.txt      # apt-mark showmanual
│   ├── all-packages.txt         # dpkg --get-selections  
│   ├── pip-packages.txt         # pip freeze
│   ├── npm-packages.txt         # npm list -g --depth=0
│   └── snap-packages.txt        # snap list
├── services/
│   ├── enabled-services.txt     # systemctl enabled services
│   ├── custom-services/         # Your custom .service files
│   ├── cron-jobs.txt           # crontab -l output
│   └── service-overrides/       # systemctl override files
├── hardware/
│   ├── hardware-info.txt        # Pi model, RAM, storage
│   ├── gpio-usage.txt          # GPIO pin assignments
│   ├── usb-devices.txt         # Connected USB devices
│   └── i2c-spi-status.txt      # I2C/SPI interface status
├── network/
│   ├── interfaces.txt           # Network interface config
│   ├── wifi-networks.txt        # Saved WiFi (no passwords)
│   ├── static-ips.txt          # Static IP configurations
│   └── firewall-rules.txt       # UFW or iptables rules
├── scripts/
│   ├── snapshot-*.sh           # Data capture scripts
│   ├── restore-*.sh            # Restoration scripts
│   ├── validate-*.sh           # Post-restore validation
│   └── utils/                  # Helper functions
├── meta/
│   ├── README.md               # Main documentation
│   ├── restore-log.txt         # Last restoration log
│   ├── snapshot-timestamp.txt  # When snapshot was taken
│   └── pi-model.txt           # Target Pi model info
└── docker/                    # If you use Docker
    ├── docker-compose.yml
    ├── container-list.txt
    └── volumes-backup/
```

## 🚀 Priority Enhancements (Phase 1)

### 1. Complete `restore-system.sh`
```bash
#!/bin/bash
set -e  # Exit on any error

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BASE_DIR="$(dirname "$SCRIPT_DIR")"
LOG_FILE="$BASE_DIR/meta/restore-log.txt"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

log "🚀 Starting system restoration..."

# 1. Update package lists
log "📦 Updating package lists..."
sudo apt update

# 2. Install packages
log "📦 Installing packages..."
if [ -f "$BASE_DIR/packages/manual-packages.txt" ]; then
    xargs sudo apt install -y < "$BASE_DIR/packages/manual-packages.txt"
fi

# 3. Restore configs
log "⚙️ Restoring configurations..."
if [ -d "$BASE_DIR/configs/etc" ]; then
    sudo rsync -av "$BASE_DIR/configs/etc/" /etc/
fi
if [ -d "$BASE_DIR/configs/user" ]; then
    rsync -av "$BASE_DIR/configs/user/" ~/
fi

# 4. Restore services
log "🔄 Restoring services..."
bash "$SCRIPT_DIR/restore-services.sh"

# 5. Validation
log "✅ Running validation..."
bash "$SCRIPT_DIR/validate-restore.sh"

log "🎉 System restoration complete!"
```

### 2. Enhanced Package Snapshotting
```bash
#!/bin/bash
# Enhanced snapshot-packages.sh

PACKAGES_DIR="../packages"
mkdir -p "$PACKAGES_DIR"

echo "📦 Snapshotting packages..."

# APT packages
apt-mark showmanual > "$PACKAGES_DIR/manual-packages.txt"
dpkg --get-selections > "$PACKAGES_DIR/all-packages.txt"

# Python packages
if command -v pip3 &> /dev/null; then
    pip3 freeze > "$PACKAGES_DIR/pip-packages.txt"
fi

# Node.js packages
if command -v npm &> /dev/null; then
    npm list -g --depth=0 > "$PACKAGES_DIR/npm-packages.txt" 2>/dev/null || true
fi

# Snap packages
if command -v snap &> /dev/null; then
    snap list > "$PACKAGES_DIR/snap-packages.txt"
fi

echo "✅ Package snapshot complete"
```

### 3. Hardware Documentation Script
```bash
#!/bin/bash
# scripts/snapshot-hardware.sh

HARDWARE_DIR="../hardware"
mkdir -p "$HARDWARE_DIR"

echo "🔧 Documenting hardware configuration..."

# Pi model and specs
cat /proc/cpuinfo | grep -E "(Hardware|Revision|Model)" > "$HARDWARE_DIR/hardware-info.txt"
free -h >> "$HARDWARE_DIR/hardware-info.txt"
df -h >> "$HARDWARE_DIR/hardware-info.txt"

# USB devices
lsusb > "$HARDWARE_DIR/usb-devices.txt"

# I2C/SPI status
raspi-config nonint get_i2c >> "$HARDWARE_DIR/i2c-spi-status.txt"
raspi-config nonint get_spi >> "$HARDWARE_DIR/i2c-spi-status.txt"

# Boot config
cp /boot/config.txt "$HARDWARE_DIR/boot-config.txt" 2>/dev/null || true

echo "✅ Hardware documentation complete"
```

### 4. Validation Script
```bash
#!/bin/bash
# scripts/validate-restore.sh

LOG_FILE="../meta/validation-log.txt"
FAILED=0

validate() {
    if [ $? -eq 0 ]; then
        echo "✅ $1" | tee -a "$LOG_FILE"
    else
        echo "❌ $1" | tee -a "$LOG_FILE"
        FAILED=1
    fi
}

echo "🔍 Validating restoration..." | tee "$LOG_FILE"

# Check if key packages are installed
if [ -f "../packages/manual-packages.txt" ]; then
    while read -r package; do
        dpkg -l | grep -q "^ii  $package "
        validate "Package $package installed"
    done < "../packages/manual-packages.txt"
fi

# Check if key services are running
if [ -f "../services/enabled-services.txt" ]; then
    while read -r line; do
        service_name=$(echo "$line" | awk '{print $1}')
        systemctl is-active "$service_name" > /dev/null
        validate "Service $service_name is running"
    done < "../services/enabled-services.txt"
fi

# Check critical configs exist
test -f ~/.bashrc
validate "User shell config exists"

if [ $FAILED -eq 0 ]; then
    echo "🎉 All validations passed!" | tee -a "$LOG_FILE"
else
    echo "⚠️ Some validations failed. Check $LOG_FILE" | tee -a "$LOG_FILE"
fi
```

## 🎯 Services Directory Strategy

The `services/` directory should contain:

1. **enabled-services.txt** - Your current approach is good
2. **custom-services/** - Directory for your custom `.service` files
3. **cron-jobs.txt** - Output of `crontab -l`
4. **service-overrides/** - Any systemctl override configurations

Example structure:
```
services/
├── enabled-services.txt
├── custom-services/
│   ├── my-app.service
│   └── backup-script.service
├── cron-jobs.txt
└── service-overrides/
    └── ssh.service.d/
        └── custom.conf
```

## 🔄 Recommended Workflow

### Daily/Weekly Snapshots
```bash
# Create a master snapshot script
#!/bin/bash
# scripts/full-snapshot.sh

echo "📸 Taking full system snapshot..."
bash snapshot-packages.sh
bash snapshot-services.sh  
bash snapshot-hardware.sh
bash backup-configs.sh

echo "$(date)" > ../meta/snapshot-timestamp.txt
echo "✅ Snapshot complete: $(date)"
```

### New Pi Setup
```bash
# On new Pi:
git clone <your-repo> pi-setup
cd pi-setup/scripts
bash restore-system.sh
```

## 📋 Next Development Phases

### Phase 2: Advanced Features
- Docker container management
- Network configuration backup/restore
- Automatic testing of restored system
- Incremental snapshots with git commits

### Phase 3: Automation
- Scheduled snapshots via cron
- Remote backup to cloud storage
- Web dashboard for monitoring
- Notification system for failed restores

## 🎯 Immediate Action Items

1. **Complete `restore-system.sh`** using the template above
2. **Create `validate-restore.sh`** for post-restore verification
3. **Enhance `snapshot-packages.sh`** to include pip/npm packages
4. **Add `snapshot-hardware.sh`** for hardware documentation
5. **Create `full-snapshot.sh`** master script
6. **Update README.md** with new usage instructions

This approach will give you a robust, self-documenting system that can reliably clone your Pi setup to new hardware while providing detailed logs and validation of the restoration process.
