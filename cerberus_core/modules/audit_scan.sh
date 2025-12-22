#!/bin/bash
# MODULE: SCORING AUDIT (Kernel + SSH + PAM)
# Requirement: "Audit dynamique ... PAM" & "Scoring"

TARGET="172.20.0.20"
USER="msfadmin"
PASS="msfadmin"

echo "📊 STARTING COMPLIANCE AUDIT ON: $TARGET"
echo "----------------------------------------"

SCORE=0

# 1. KERNEL CHECK (Worth 30 pts)
# Requirement: Check 'sysctl' params
IP_FWD=$(sshpass -p "$PASS" ssh -o StrictHostKeyChecking=no $USER@$TARGET "cat /proc/sys/net/ipv4/ip_forward" 2>/dev/null)

if [ "$IP_FWD" == "0" ]; then
    echo "✅ [PASS] Kernel: IP Forwarding Disabled (+30 pts)"
    SCORE=$((SCORE + 30))
else
    echo "❌ [FAIL] Kernel: IP Forwarding Enabled (Risk: Routing Attacks)"
fi

# 2. SSH CHECK (Worth 30 pts)
# Requirement: Check SSH Configuration
ROOT_LOGIN=$(sshpass -p "$PASS" ssh $USER@$TARGET "grep '^PermitRootLogin yes' /etc/ssh/sshd_config" 2>/dev/null)

if [ -z "$ROOT_LOGIN" ]; then
    echo "✅ [PASS] SSH: Root Login Disabled (+30 pts)"
    SCORE=$((SCORE + 30))
else
    echo "❌ [FAIL] SSH: Root Login Allowed"
fi

# 3. PAM CHECK (Worth 40 pts)
# Requirement: Check Pluggable Authentication Modules (Password Policy)
# We look for 'minlen=12' (Minimum password length of 12)
PAM_CHECK=$(sshpass -p "$PASS" ssh $USER@$TARGET "grep 'minlen=12' /etc/pam.d/common-password" 2>/dev/null)

if [ ! -z "$PAM_CHECK" ]; then
    echo "✅ [PASS] PAM: Password Complexity Enforced (+40 pts)"
    SCORE=$((SCORE + 40))
else
    echo "❌ [FAIL] PAM: Password Complexity Missing (Risk: Weak Passwords)"
fi

echo "----------------------------------------"
echo "🏆 FINAL SECURITY SCORE: $SCORE / 100"
echo "----------------------------------------"

# Save to Log (Requirement: "Rapport")
LOG_FILE="/app/reports/audit_$(date +%F_%T).json"
echo "{ \"target\": \"$TARGET\", \"score\": $SCORE, \"timestamp\": \"$(date)\" }" >> "$LOG_FILE"
