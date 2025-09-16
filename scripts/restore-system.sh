# scripts/restore-system.sh
#!/bin/bash
echo "Installing packages..."
xargs sudo apt install -y < ../packages/manual-packages.txt

echo "Restoring configs..."
sudo rsync -av ../configs/etc/ /etc/
rsync -av ../configs/user/ ~/

echo "Reloading services..."
sudo systemctl daemon-reexec

# Shell detection

detect_shell() {
  case "$SHELL" in
    */bash) echo "Detected Bash shell";;
    */zsh)  echo "Detected Zsh shell";;
    */fish) echo "Detected Fish shell";;
    *)      echo "Unknown shell: $SHELL";;
  esac
}

echo "🔍 Detecting shell..."
detect_shell

# Continue with restore logic...
