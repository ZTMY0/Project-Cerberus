#!/bin/bash
# MODULE: HEAVY DUTY HARDENING
TARGET="172.20.0.20"
USER="msfadmin"
PASS="msfadmin"

echo "🛡️  APPLYING SECURITY HARDENING (VERBOSE MODE)..."
echo "---------------------------------"

# 1. FIX KERNEL (Sysctl)
echo "[+] 1. Disabling IP Forwarding..."
sshpass -p "$PASS" ssh -tt $USER@$TARGET "echo $PASS | sudo -S sysctl -w net.ipv4.ip_forward=0"

# 2. FIX SSH (Sed + Reload)
echo "[+] 2. Disabling Root Login..."
sshpass -p "$PASS" ssh -tt $USER@$TARGET "echo $PASS | sudo -S sed -i 's/PermitRootLogin yes/PermitRootLogin no/' /etc/ssh/sshd_config"
sshpass -p "$PASS" ssh -tt $USER@$TARGET "echo $PASS | sudo -S pkill -HUP sshd"

# 3. FIX PAM (Password Policy)
echo "[+] 3. Enforcing Password Complexity (PAM)..."
# We check if the fix is already there to avoid duplicates
CHECK=$(sshpass -p "$PASS" ssh $USER@$TARGET "grep 'minlen=12' /etc/pam.d/common-password")
if [ -z "$CHECK" ]; then
    sshpass -p "$PASS" ssh -tt $USER@$TARGET "echo $PASS | sudo -S sed -i 's/pam_unix.so obscure sha512/pam_unix.so obscure sha512 minlen=12/' /etc/pam.d/common-password"
    echo "    -> PAM Config Updated."
else
    echo "    -> PAM already patched."
fi

echo "---------------------------------"
echo "✅ Hardening Run Complete."
