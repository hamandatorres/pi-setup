# scripts/snapshot-packages.sh
#!/bin/bash
apt-mark showmanual > ../packages/manual-packages.txt
dpkg --get-selections > ../packages/all-packages.txt
