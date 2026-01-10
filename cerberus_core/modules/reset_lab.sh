#!/bin/bash
# CERBERUS: RESET MODULE (Enterprise Grade)

LOG_FILE="/app/reports/audit_$(date +%F).log"

echo "========================================================"
echo " [!] SYSTEM RESET: RESTORING DEFAULT STATE"
echo "========================================================"

# --- 1. RESET KERNEL (Vulnerable Mode) ---
echo -n "[*] Re-enabling IP Forwarding...      "

# A. Persistence: Remove secure config
sed -i '/net.ipv4.ip_forward/d' /etc/sysctl.conf
echo "net.ipv4.ip_forward = 1" >> /etc/sysctl.conf

# B. Immediate: Set live kernel to '1' (Router Mode)
sysctl -w net.ipv4.ip_forward=1 > /dev/null
echo "[DONE]"

# --- 2. RESET PAM (Default Mode) ---
echo -n "[*] Removing Password Rules...        "
sed -i '/minlen=12/d' /etc/pam.d/common-password
echo "[DONE]"

echo "--------------------------------------------------------"
echo " [WARNING] System is now in VULNERABLE state."
echo "========================================================"

# Log critical event
echo "$(date '+%Y-%m-%d %H:%M:%S') | LEVEL=CRITICAL | MODULE=RESET | ACTION=RESTORE_DEFAULTS" >> "$LOG_FILE"

read -p "Press Enter to return..."