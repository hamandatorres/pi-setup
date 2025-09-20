# 🧰 Raspberry Pi Setup Toolkit

This repo captures the full system state of my Raspberry Pi — installed packages, configs, services, and custom scripts — so I can restore or migrate my setup with minimal effort.

## 📦 What Gets Captured

### Package Management
- **APT packages**: `packages/manual-packages.txt` (292 packages)
- **APT package status**: `packages/all-packages.txt` (972 total packages)  
- **APT sources**: `packages/apt-sources/` (8 source files)
- **Python packages**: `packages/pip-all-packages.txt` (97 packages)
- **Node.js packages**: `packages/npm-package-names.txt` (3 global packages)
- **pipx packages**: `packages/pipx-packages.txt`

### Configuration Backups
- **System configs**: `configs/etc/` (complete /etc/ backup)
- **User configs**: `configs/user/` (dotfiles, .config, SSH keys)
- **Boot configs**: `configs/boot/` (Pi-specific boot settings)

### Services & Scheduling
- **Enabled services**: `services/enabled-services.txt` (40 services)
- **Cron jobs**: `services/cron-jobs.txt` (7 scheduled tasks)

## � Usage

### Take a Complete Snapshot
```bash
cd scripts/
./take-full-snapshot.sh
```

### Restore Everything on New System
```bash
cd scripts/
./restore-system.sh
./validate-restore.sh
```

### Individual Operations
```bash
# Capture specific components
./snapshot-packages.sh       # APT packages
./snapshot-pip-packages.sh   # Python packages  
./snapshot-npm-packages.sh   # Node.js packages
./snapshot-services.sh       # System services
./snapshot-cron.sh          # Cron jobs
./backup-configs.sh         # Configuration files

# Restore components
./restore-system.sh         # Full restoration
./restore-services.sh       # Services only
./validate-restore.sh       # Verify everything worked
```

## 📊 Current State
- ✅ **292 manual packages** captured and ready to restore
- ✅ **972 total packages** with installation status tracked
- ✅ **97 Python packages** ready for restoration
- ✅ **3 Node.js packages** captured
- ✅ **40 system services** with enable/start automation
- ✅ **7 cron jobs** backed up and restorable
- ✅ **Complete config backup** (24MB total)
- ✅ **Boot configuration** (Pi-specific settings)
- ✅ **Comprehensive validation** suite

## 🧠 Philosophy
Modular, version-controlled, and portable. Designed for rollback, sync, and audit across Pi upgrades or failures.

**Total backup size: 24MB** - Complete system state in a tiny package!
