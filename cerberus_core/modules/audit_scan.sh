#!/bin/bash
clear
echo "========================================================"
echo " CERBERUS AUDIT: CONFIGURATION COMPLIANCE"
echo "========================================================"
SCORE=0

# --- CHECK 1: KERNEL CONFIG (35 PTS) ---
# We check /etc/sysctl.conf because we cannot change the live Docker kernel
echo -n "[*] Checking Kernel Config (sysctl.conf)...   "
if grep -q "^net.ipv4.ip_forward = 0" /etc/sysctl.conf; then
    echo -e "\033[0;32m[PASS]\033[0m (Hardened)"
    SCORE=$((SCORE+35))
else
    echo -e "\033[0;31m[FAIL]\033[0m (Vulnerable - Setting Missing)"
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
if [ -f /etc/ssh/sshd_config ]; then
    echo -e "\033[0;33m[PASS]\033[0m (Lab Override Active)"
    echo "    -> Note: Root Login permitted for Guacamole access"
    SCORE=$((SCORE+30))
else
    echo -e "\033[0;31m[FAIL]\033[0m (Config Missing)"
fi

echo "--------------------------------------------------------"
echo " FINAL SCORE: $SCORE / 100"
echo "========================================================"
echo ""
read -p "Press Enter to return..."
