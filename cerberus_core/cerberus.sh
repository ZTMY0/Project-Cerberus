#!/bin/bash
# ============================================================
# PROJECT CERBERUS: Automated Purple Team Framework
# Student Project - 2025
# ============================================================

# --- 1. SETUP & CONFIG ---
BASE_DIR="/app"
MODULES_DIR="$BASE_DIR/modules"
# Fallback target if config file is missing
TARGET_IP="172.20.0.20"
REPORT_DIR="/app/reports"

# Ensure report directory exists
mkdir -p "$REPORT_DIR"

# Colors for the UI
BLUE='\033[1;34m'
CYAN='\033[0;36m'
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# --- 2. UI FUNCTIONS ---
show_banner() {
    clear
    echo -e "${BLUE}"
    echo "   (                      "
    echo "   )\ )            )      "
    echo "  (()/(   (     ( /(   (  "
    echo "   /(_))  )\ )  )\())  )\ "
    echo "  (_))   (()/( ((_)\  ((_)"
    echo "  / __|   )(_)) _((_)  (_)"
    echo "  | (__   | || | | '_|  | | "
    echo "   \___|   \_, | |_|    |_| "
    echo "           |__/             "
    echo -e "${NC}"
    echo -e "   ${CYAN}PROJECT CERBERUS${NC} | Automated Security Framework"
    echo "----------------------------------------------------"
    echo -e "   TARGET: ${YELLOW}$TARGET_IP${NC}"
    echo "----------------------------------------------------"
}

# --- 3. MAIN EXECUTION LOOP ---
while true; do
    show_banner
    
    echo -e "${GREEN}1.${NC}  Scan & Audit"
    echo -e "${GREEN}2.${NC}  Harden & Fix"
    echo -e "${GREEN}3.${NC}  Attack Simulation (ARP Poisoning )"
    echo -e "${GREEN}4.${NC}  View Latest Report"
    echo -e "${RED}5.${NC}    Exit / Disconnect"
    echo "----------------------------------------------------"
    
    read -p "Select Operation [1-5]: " CHOICE

    case $CHOICE in
        1)
            # Run the Audit
            echo -e "\n${CYAN}[*] Initializing Audit Module...${NC}"
            sleep 1
            $MODULES_DIR/audit_scan.sh
            read -p "Press Enter to return..."
            ;;
        2)
            # Run the Hardener
            echo -e "\n${CYAN}[*] Loading Remediation Scripts...${NC}"
            sleep 1
            $MODULES_DIR/harden_fix.sh
            read -p "Press Enter to return..."
            ;;
        3)
            # Run the Attack
            echo -e "\n${RED}[!] WARNING: ENGAGING OFFENSIVE MODULE...${NC}"
            sleep 1
            $MODULES_DIR/attack_arp.sh
            read -p "Press Enter to return..."
            ;;
        4)
            # View Reports
            echo -e "\n${CYAN}[*] Fetching Session Report...${NC}"
            echo "----------------------------------------------------"
            if [ -f "$REPORT_DIR/session_status.json" ]; then
                cat "$REPORT_DIR/session_status.json"
            else
                echo -e "${YELLOW}No reports generated yet.${NC}"
            fi
            echo ""
            echo "----------------------------------------------------"
            read -p "Press Enter to return..."
            ;;
        5)
            echo -e "\n${BLUE}🐺 Cerberus Protocol Terminated.${NC}"
            exit 0
            ;;
        *)
            echo -e "\n${RED}Invalid Selection.${NC}"
            sleep 1
            ;;
    esac
done