# scripts/restore-system.sh
#!/bin/bash
echo "Installing packages..."
xargs sudo apt install -y < ../packages/manual-packages.txt

echo "Restoring configs..."
sudo rsync -av ../configs/etc/ /etc/
rsync -av ../configs/user/ ~/

echo "Reloading services..."
sudo systemctl daemon-reexec
