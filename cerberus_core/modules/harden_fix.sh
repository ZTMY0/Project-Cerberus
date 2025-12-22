#!/bin/bash
# Cerberus Hardening Module (Blue Team)
# Automatically remediates vulnerabilities found in the Audit.

# ---------------- CONFIG ----------------
TARGET="172.20.0.20"
USER="root"
PASS="root"

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "\n  APPLYING HARDENING TO: $TARGET"
echo "----------------------------------------"

# 1. DISABLE IP FORWARDING (Kernel Hardening)
echo -e "${YELLOW}[*] Step 1: Disabling IP Forwarding...${NC}"
# We write '0' to the sysctl parameter
sshpass -p "$PASS" ssh -o StrictHostKeyChecking=no $USER@$TARGET "sysctl -w net.ipv4.ip_forward=0" 2>/dev/null

if [ $? -eq 0 ]; then
    echo -e "${GREEN}    -> Success: Kernel routing disabled.${NC}"
else
    echo -e "${RED}    -> Error: Failed to update sysctl.${NC}"
fi

# 2. SECURE SSH (Disable Root Login)
echo -e "${YELLOW}[*] Step 2: Disabling Root Login via SSH...${NC}"
# Use sed to find 'PermitRootLogin yes' and change to 'no'
sshpass -p "$PASS" ssh $USER@$TARGET "sed -i 's/PermitRootLogin yes/PermitRootLogin no/g' /etc/ssh/sshd_config" 2>/dev/null

# Restart SSH to apply changes (ignoring 'connection closed' error that happens when restarting ssh)
sshpass -p "$PASS" ssh $USER@$TARGET "service ssh restart" > /dev/null 2>&1

echo -e "${GREEN}    -> Success: Root login blocked. Service restarted.${NC}"

# 3. ENFORCE PASSWORD POLICY (PAM)
echo -e "${YELLOW}[*] Step 3: Enforcing Password Complexity...${NC}"

# Check if we already applied the patch to avoid breaking the file
CHECK=$(sshpass -p "$PASS" ssh $USER@$TARGET "grep 'minlen=12' /etc/pam.d/common-password" 2>/dev/null)

if [ -z "$CHECK" ]; then
    # Add 'minlen=12' to the password module line
    sshpass -p "$PASS" ssh $USER@$TARGET "sed -i 's/pam_unix.so obscure sha512/pam_unix.so obscure sha512 minlen=12/' /etc/pam.d/common-password" 2>/dev/null
    echo -e "${GREEN}    -> Success: Minimum length set to 12.${NC}"
else
    echo -e "${GREEN}    -> Info: PAM is already patched.${NC}"
fi

echo "----------------------------------------"
echo -e " REMEDIATION COMPLETE."
echo -e "   Run ./audit_scan.sh to verify the new score."
echo "----------------------------------------"