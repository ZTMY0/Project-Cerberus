#!/bin/bash
# Install tcpdump if missing
command -v tcpdump >/dev/null 2>&1 || apt-get install -y tcpdump >/dev/null 2>&1

clear
echo "========================================================"
echo " CERBERUS NETWORK ANALYZER"
echo "========================================================"
echo "[*] Interface: eth0"
echo "[*] Mode:      Live Inspection"
echo "--------------------------------------------------------"
echo -e "\033[1;32m[!] CAPTURE STARTED. TRAFFIC WILL APPEAR BELOW.\033[0m"
echo -e "    (Press \033[1;37mENTER\033[0m to stop the capture)"
echo "--------------------------------------------------------"

# 1. Start tcpdump in the background (&) so it doesn't block the script
tcpdump -i eth0 -n &

# 2. Capture the Process ID (PID) of the background tcpdump
TCPDUMP_PID=$!

# 3. Wait for user input (This holds the script open)
read -r _

# 4. Kill the specific tcpdump process when Enter is pressed
kill "$TCPDUMP_PID" > /dev/null 2>&1
wait "$TCPDUMP_PID" 2>/dev/null

echo ""
echo "--------------------------------------------------------"
echo "[*] CAPTURE STOPPED BY USER."
echo "========================================================"
echo ""
read -p "Press Enter to return to menu..."
