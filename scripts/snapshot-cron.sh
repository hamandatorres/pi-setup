#!/bin/bash
# scripts/snapshot-cron.sh
# Capture cron jobs

set -e

# Get script directory and base directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BASE_DIR="$(dirname "$SCRIPT_DIR")"

# Ensure services directory exists
mkdir -p "$BASE_DIR/services"

echo "⏰ Capturing cron jobs..."

# Capture user's cron jobs
if crontab -l &>/dev/null; then
    crontab -l > "$BASE_DIR/services/cron-jobs.txt"
    cron_count=$(grep -c "^[^#]" "$BASE_DIR/services/cron-jobs.txt" 2>/dev/null || echo 0)
    echo "✅ Captured $cron_count user cron jobs"
else
    echo "# No cron jobs found" > "$BASE_DIR/services/cron-jobs.txt"
    echo "⚠️ No user cron jobs found"
fi

# Also capture system-wide cron if accessible
echo "📋 Attempting to capture system cron information..."

# List system cron directories for reference
{
    echo "# System cron directories and files:"
    echo "# Generated on $(date)"
    echo ""
    
    # List cron.d contents if readable
    if [ -d "/etc/cron.d" ] && [ -r "/etc/cron.d" ]; then
        echo "# /etc/cron.d/ contents:"
        ls -la /etc/cron.d/ 2>/dev/null | sed 's/^/# /' || echo "# Cannot read /etc/cron.d/"
        echo ""
    fi
    
    # List other cron directories
    for crondir in "/etc/cron.hourly" "/etc/cron.daily" "/etc/cron.weekly" "/etc/cron.monthly"; do
        if [ -d "$crondir" ] && [ -r "$crondir" ]; then
            echo "# $crondir contents:"
            ls -la "$crondir" 2>/dev/null | sed 's/^/# /' || echo "# Cannot read $crondir"
            echo ""
        fi
    done
    
    # Add actual user cron jobs
    echo "# User cron jobs for $(whoami):"
    if crontab -l &>/dev/null; then
        crontab -l
    else
        echo "# No user cron jobs"
    fi
    
} > "$BASE_DIR/services/cron-jobs.txt"

echo "✅ Cron information saved to services/cron-jobs.txt"
echo "📁 File: $BASE_DIR/services/cron-jobs.txt"
echo "💡 Note: Only user cron jobs can be automatically restored"
echo "🎉 Cron capture complete!"