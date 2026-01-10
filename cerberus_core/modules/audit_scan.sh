#!/bin/bash
# CERBERUS: AUDIT MODULE (Enterprise Grade)

SCORE=0
LOG_FILE="/app/reports/audit_$(date +%F).log"

echo "========================================================"
echo " CERBERUS AUDIT: CONFIGURATION COMPLIANCE"
echo "========================================================"

# --- 1. KERNEL CHECK (Source of Truth: /proc) ---
# We check the active value in memory.
KERN_VAL=$(cat /proc/sys/net/ipv4/ip_forward)

if [ "$KERN_VAL" -eq 0 ]; then
    echo -e "[*] Kernel: IP Forwarding           \e[32m[PASS]\e[0m (Disabled/Secure)"
    SCORE=$((SCORE + 50))
    R1="PASS"
else
    echo -e "[*] Kernel: IP Forwarding           \e[31m[FAIL]\e[0m (Enabled/Vulnerable)"
    R1="FAIL"
fi

# --- 2. PAM CHECK (Source of Truth: Configuration File) ---
# We look for the specific compliance rule 'minlen=12'.
if grep -q "minlen=12" /etc/pam.d/common-password; then
    echo -e "[*] PAM: Password Complexity        \e[32m[PASS]\e[0m (Enforced)"
    SCORE=$((SCORE + 50))
    R2="PASS"
else
    echo -e "[*] PAM: Password Complexity        \e[31m[FAIL]\e[0m (Not Found)"
    R2="FAIL"
fi

echo "--------------------------------------------------------"
echo " FINAL COMPLIANCE SCORE: $SCORE / 100"
echo "========================================================"

# Write structured log for SIEM
echo "$(date '+%Y-%m-%d %H:%M:%S') | LEVEL=INFO | MODULE=AUDIT | SCORE=$SCORE | KERNEL=$R1 | PAM=$R2" >> "$LOG_FILE"

read -p "Press Enter to return..."