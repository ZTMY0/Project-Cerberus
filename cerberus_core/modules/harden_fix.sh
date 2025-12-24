#!/bin/bash
clear
echo "[*] APPLYING SECURITY HARDENING..."
echo "--------------------------------------------------------"

# KERNEL
if [ "$(sysctl -n net.ipv4.ip_forward)" != "0" ]; then
    echo "net.ipv4.ip_forward = 0" >> /etc/sysctl.conf
    sysctl -p > /dev/null 2>&1
    echo "[+] Kernel: IP Forwarding Disabled"
else
    echo "[-] Kernel: Already Hardened"
fi

# PAM
if ! grep -q "minlen=12" /etc/pam.d/common-password; then
    echo "password required pam_unix.so minlen=12" >> /etc/pam.d/common-password
    echo "[+] PAM: Password Complexity Enforced"
else
    echo "[-] PAM: Already Hardened"
fi

echo "--------------------------------------------------------"
echo " HARDENING COMPLETE."
read -p "Press Enter to return..."
