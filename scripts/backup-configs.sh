# scripts/backup-configs.sh
#!/bin/bash
rsync -av --exclude='*.log' /etc ../configs/etc/
rsync -av ~/.config ../configs/user/
rsync -av ~/.bashrc ../configs/user/bashrc
rsync -av ~/.zshrc ../configs/user/zshrc
