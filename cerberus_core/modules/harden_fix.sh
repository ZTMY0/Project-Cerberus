#!/bin/bash
# CERBERUS HARDENING TOOL

if [ -d "/app/reports" ]; then LOG_DIR="/app/reports"; else LOG_DIR="./reports"; fi
mkdir -p "$LOG_DIR"
TODAY=$(date +%F)
LOG_FILE="$LOG_DIR/audit_$TODAY.log"

log_event() {
    TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
    echo "{\"timestamp\": \"$TIMESTAMP\", \"event_type\": \"$1\", \"severity\": \"$2\", \"target\": \"172.20.0.10\", \"message\": \"$3\", \"threat_score\": $4}" >> "$LOG_FILE"
}

clear
echo "[*] APPLYING SECURITY HARDENING..."
echo "--------------------------------------------------------"

CHANGES_MADE=0

# KERNEL FIX
if [ "$(sysctl -n net.ipv4.ip_forward)" != "0" ]; then
    echo "net.ipv4.ip_forward = 0" >> /etc/sysctl.conf
    sysctl -p > /dev/null 2>&1
    echo "[+] Kernel: IP Forwarding Disabled"
    log_event "HARDENING_ACTION" "Disabled IPv4 Forwarding in sysctl" "INFO" 0
    CHANGES_MADE=$((CHANGES_MADE+1))
else
    echo "[-] Kernel: Already Hardened"
fi

# PAM FIX
if ! grep -q "minlen=12" /etc/pam.d/common-password; then
    echo "password required pam_unix.so minlen=12" >> /etc/pam.d/common-password
    echo "[+] PAM: Password Complexity Enforced"
    log_event "HARDENING_ACTION" "Enforced minlen=12 in PAM" "INFO" 0
    CHANGES_MADE=$((CHANGES_MADE+1))
else
    echo "[-] PAM: Already Hardened"
fi

echo "--------------------------------------------------------"
if [ $CHANGES_MADE -gt 0 ]; then
    echo " HARDENING COMPLETE. ($CHANGES_MADE changes applied)"
else
    echo " SYSTEM ALREADY SECURE. No changes needed."
fi

read -p "Press Enter to return..."