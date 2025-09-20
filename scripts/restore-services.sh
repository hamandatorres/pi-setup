#!/bin/bash

LOG_FILE="../meta/service-restore.log"
ENABLED_SERVICES="../services/enabled-services.txt"

echo "🔄 Restoring enabled services..." | tee "$LOG_FILE"
echo "🕒 $(date)" >> "$LOG_FILE"

while read -r line; do
  service_name=$(echo "$line" | awk '{print $1}')
  
  if systemctl list-unit-files | grep -q "$service_name"; then
    echo "✅ Found $service_name" | tee -a "$LOG_FILE"
    
    if sudo systemctl enable "$service_name" >> "$LOG_FILE" 2>&1; then
      echo "🔔 Enabled $service_name" | tee -a "$LOG_FILE"
    else
      echo "❌ Failed to enable $service_name" | tee -a "$LOG_FILE"
    fi

    if sudo systemctl start "$service_name" >> "$LOG_FILE" 2>&1; then
      echo "🚀 Started $service_name" | tee -a "$LOG_FILE"
    else
      echo "⚠️ Failed to start $service_name" | tee -a "$LOG_FILE"
    fi

  else
    echo "⚠️ Service $service_name not found — skipping" | tee -a "$LOG_FILE"
  fi
done < "$ENABLED_SERVICES"

echo "✅ Service restoration complete." | tee -a "$LOG_FILE"
