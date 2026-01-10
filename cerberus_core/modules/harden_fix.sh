#!/bin/bash
# CERBERUS: HARDENING MODULE (Enterprise Grade)

echo "========================================================"
echo " CERBERUS HARDENING ENGINE"
echo "========================================================"

# --- 1. KERNEL HARDENING ---
echo -n "[*] Securing Kernel Parameters...     "

# A. Persistence: Edit the file for next reboot
if [ ! -f /etc/sysctl.conf ]; then touch /etc/sysctl.conf; fi
sed -i '/net.ipv4.ip_forward/d' /etc/sysctl.conf
echo "net.ipv4.ip_forward = 0" >> /etc/sysctl.conf

# B. Immediate: Apply to live system using standard tool
sysctl -w net.ipv4.ip_forward=0 > /dev/null
echo "[FIXED]"

# --- 2. PAM HARDENING ---
echo -n "[*] Enforcing Password Policy...      "

# Check to avoid duplicate entries
if grep -q "minlen=12" /etc/pam.d/common-password; then
    echo "[SKIP] (Already Compliant)"
else
    # Append rule safely
    echo "password required pam_unix.so minlen=12" >> /etc/pam.d/common-password
    echo "[FIXED]"
fi

echo "--------------------------------------------------------"
echo " [SUCCESS] Remediation applied successfully."
echo "========================================================"
read -p "Press Enter to return..."