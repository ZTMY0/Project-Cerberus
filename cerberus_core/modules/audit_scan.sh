#!/bin/bash
# Cerberus Audit Module
# Checks security settings on the target and calculates a score.

# ---------------- CONFIG ----------------
TARGET="172.20.0.20"
USER="root"        
PASS="root"         
REPORT_FILE="/app/reports/session_status.json"

GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "\n🔍 STARTING AUDIT ON: $TARGET"
echo "----------------------------------------"

SCORE=0

# --- 1. CHECK KERNEL FORWARDING ---
# If this is 1, the machine acts like a router (dangerous)
IP_FWD=$(sshpass -p "$PASS" ssh -o StrictHostKeyChecking=no $USER@$TARGET "cat /proc/sys/net/ipv4/ip_forward" 2>/dev/null)

if [ "$IP_FWD" == "0" ]; then
    echo -e "${GREEN}[PASS]${NC} Kernel: IP Forwarding is OFF (+30 pts)"
    SCORE=$((SCORE + 30))
else
    echo -e "${RED}[FAIL]${NC} Kernel: IP Forwarding is ON"
fi

# --- 2. CHECK SSH ROOT LOGIN ---
# Root shouldn't be able to log in directly
ROOT_LOGIN=$(sshpass -p "$PASS" ssh $USER@$TARGET "grep '^PermitRootLogin yes' /etc/ssh/sshd_config" 2>/dev/null)

if [ -z "$ROOT_LOGIN" ]; then
    echo -e "${GREEN}[PASS]${NC} SSH: Root Login Disabled (+30 pts)"
    SCORE=$((SCORE + 30))
else
    echo -e "${RED}[FAIL]${NC} SSH: Root Login is ALLOWED"
fi

# --- 3. CHECK PASSWORD POLICY ---
# checking if minimum length 12 is required
PAM_CHECK=$(sshpass -p "$PASS" ssh $USER@$TARGET "grep 'minlen=12' /etc/pam.d/common-password" 2>/dev/null)

if [ ! -z "$PAM_CHECK" ]; then
    echo -e "${GREEN}[PASS]${NC} PAM: Strong Password Policy Found (+40 pts)"
    SCORE=$((SCORE + 40))
else
    echo -e "${RED}[FAIL]${NC} PAM: No Complexity Rules Found"
fi

echo "----------------------------------------"
echo " CURRENT SCORE: $SCORE / 100"

# --- REPORTING (SMART UPDATE) ---
# This part checks if we already scanned this machine.
# If yes, it compares the scores. If no, it sets a baseline.

TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')

if [ ! -f "$REPORT_FILE" ]; then
    # First time running? Create the file.
    echo "{\"target\": \"$TARGET\", \"baseline\": $SCORE, \"current\": $SCORE, \"last_scan\": \"$TIMESTAMP\"}" > $REPORT_FILE
    echo -e "\n [INFO] First scan saved. Baseline set to $SCORE."

else
    # File exists? Read the old baseline score.
    # Using simple grep/cut to avoid needing complex tools
    OLD_BASE=$(grep -o '"baseline": [0-9]*' $REPORT_FILE | cut -d' ' -f2)
    
    # Calculate improvement
    DIFF=$((SCORE - OLD_BASE))
    
    # Overwrite file with new current score, but KEkeepEP the old baseline
    echo "{\"target\": \"$TARGET\", \"baseline\": $OLD_BASE, \"current\": $SCORE, \"last_scan\": \"$TIMESTAMP\"}" > $REPORT_FILE
    
    echo -e "\n IMPROVEMENT REPORT:"
    if [ $DIFF -gt 0 ]; then
        echo -e "${GREEN} Security improved by +$DIFF points${NC}"
    elif [ $DIFF -lt 0 ]; then
        echo -e "${RED} Warning: Score dropped by $DIFF points.${NC}"
    else
        echo "  No changes detected since first scan."
    fi
fi
echo "----------------------------------------"