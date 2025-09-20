# scripts/snapshot-services.sh
#!/bin/bash
systemctl list-unit-files --type=service --state=enabled > ../services/enabled-services.txt
