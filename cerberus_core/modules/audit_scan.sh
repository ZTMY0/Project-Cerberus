#!/bin/bash
# CERBERUS AUDIT SCANNER

# determine where reports are stored (Handles Docker paths)
if [ -d "/app/reports" ]; then LOG_DIR="/app/reports"; else LOG_DIR="./reports"; fi
mkdir -p "$LOG_DIR"
TODAY=$(date +%F)
LOG_FILE="$LOG_DIR/audit_$TODAY.log"

log_event() {
    TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
    echo "{\"timestamp\": \"$TIMESTAMP\", \"event_type\": \"$1\", \"severity\": \"$2\", \"target\": \"172.20.0.10\", \"message\": \"$3\", \"threat_score\": $4}" >> "$LOG_FILE"
}

clear
echo "========================================================"
echo " CERBERUS AUDIT: CONFIGURATION COMPLIANCE"
echo "========================================================"
SCORE=0

# --- CHECK 1: KERNEL CONFIG (35 PTS) ---
echo -n "[*] Checking Kernel Config (sysctl.conf)...   "

# Logic: Check if file exists AND if the setting is correct
if [ -f /etc/sysctl.conf ] && grep -q "^net.ipv4.ip_forward = 0" /etc/sysctl.conf; then
    echo -e "\033[0;32m[PASS]\033[0m (Hardened)"
    SCORE=$((SCORE+35))
else
    # If file is missing OR setting is wrong, it fails cleanly
    echo -e "\033[0;31m[FAIL]\033[0m (Vulnerable - Forwarding Enabled or Config Missing)"
fi

# --- CHECK 2: PAM PASSWORD POLICY (35 PTS) ---
echo -n "[*] Checking PAM Password Complexity...       "
if grep -q "minlen=12" /etc/pam.d/common-password; then
    echo -e "\033[0;32m[PASS]\033[0m (MinLen=12 Enforced)"
    SCORE=$((SCORE+35))
else
    echo -e "\033[0;31m[FAIL]\033[0m (Default Policy)"
fi

# --- CHECK 3: SSH CONFIG (30 PTS) ---
echo -n "[*] Checking SSH Root Login Policy...         "
# We check if root login is allowed (For this project, we want it ON for Guacamole, so we give points for it existing)
if grep -q "PermitRootLogin yes" /etc/ssh/sshd_config; then
    echo -e "\033[0;33m[PASS]\033[0m (Access Active)"
    SCORE=$((SCORE+30))
else
    echo -e "\033[0;31m[FAIL]\033[0m (Config Mismatch)"
fi

echo "--------------------------------------------------------"
echo " FINAL SCORE: $SCORE / 100"
echo "========================================================"

log_event "COMPLIANCE_SCAN" "Audit completed with score $SCORE/100" "INFO" "$SCORE"
echo "[+] Audit result logged to $LOG_FILE"
echo ""
read -p "Press Enter to return..."