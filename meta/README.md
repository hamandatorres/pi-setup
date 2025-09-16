# 🧰 Raspberry Pi Setup Toolkit

This repo captures the full system state of my Raspberry Pi — installed packages, configs, services, and custom scripts — so I can restore or migrate my setup with minimal effort.

## 📦 Package Snapshot
- `packages/manual-packages.txt`: Explicitly installed packages
- `packages/all-packages.txt`: Full package list

## ⚙️ Config Backups
- `configs/etc/`: System-wide configs
- `configs/user/`: User-level configs (`~/.config`, shell profiles)

## 🔁 Restore Script
Run `scripts/restore-system.sh` to reinstall packages, restore configs, and reload services.

## 🧠 Philosophy
Modular, version-controlled, and portable. Designed for rollback, sync, and audit across Pi upgrades or failures.

## 🚀 Usage
```bash
bash scripts/snapshot-packages.sh
bash scripts/backup-configs.sh
bash scripts/restore-system.sh
