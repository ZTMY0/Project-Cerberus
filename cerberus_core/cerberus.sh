#!/bin/bash
# CERBERUS MAIN CONTROLLER
# Complete Audit, Hardening & Attack Framework

# Determine correct log path (Docker vs Local)
if [ -d "/app/reports" ]; then LOG_DIR="/app/reports"; else LOG_DIR="./reports"; fi
mkdir -p "$LOG_DIR"
TODAY=$(date +%F)
LOG_FILE="$LOG_DIR/audit_$TODAY.log"

# Function to log menu actions
log_event() {
    TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
    # $1=Event, $2=Message, $3=Severity, $4=Score
    echo "{\"timestamp\": \"$TIMESTAMP\", \"event_type\": \"$1\", \"severity\": \"$2\", \"target\": \"172.20.0.10\", \"message\": \"$3\", \"threat_score\": $4}" >> "$LOG_FILE"
}

chmod +x /app/modules/*.sh 2>/dev/null

log_event "SESSION_START" "User accessed Cerberus Main Menu" "INFO" 0

while true; do
    clear
    cat << "BANNER"

█▀▀ █▀▀ █▀█ █▄▄ █▀▀ █▀█ █ █ █▀
█▄▄ ██▄ █▀▄ █▄█ ██▄ █▀▄ ▀▄▀ ▄█

      AUTOMATED SECURITY FRAMEWORK v3.0
BANNER
    echo "--------------------------------------------------------"
    echo "   TARGET: $(hostname -I | cut -d' ' -f1)"
    echo "   KERNEL: $(uname -r)"
    echo "--------------------------------------------------------"
    echo " 1.  Dynamic Vulnerability Audit"
    echo " 2.  Apply Hardening"
    echo " 3.  Internal Attack Simulation (ARP Poisoning)"
    echo " 4.  RESET LAB TO VULNERABLE STATE"
    echo " 5.  Exit"
    echo "--------------------------------------------------------"
    read -p " Select Operation [1-5]: " choice

    case $choice in
        1) 
            log_event "MENU_SELECTION" "Selected: Dynamic Vulnerability Audit" "INFO" 0
            /app/modules/audit_scan.sh 
            ;;
        2) 
            log_event "MENU_SELECTION" "Selected: Apply Hardening" "INFO" 0
            /app/modules/harden_fix.sh 
            ;;
        3) 
            log_event "MENU_SELECTION" "Selected: Internal Attack Simulation (MITM)" "INFO" 0
            /app/modules/attack_arp.sh 
            ;;
        4) 
            echo "[!] RESETTING CONFIGURATIONS..."
            # Log this as a CRITICAL event because it removes security
            log_event "SYSTEM_RESET" "User initiated factory reset (Vulnerable State)" "CRITICAL" 100
            
            # Remove Kernel Hardening (IP Forwarding)
            sed -i '/net.ipv4.ip_forward/d' /etc/sysctl.conf
            
            # Remove Password Policy
            sed -i '/minlen=12/d' /etc/pam.d/common-password
            
            echo " SYSTEM RESET TO VULNERABLE."
            read -p "Press Enter..." 
            ;;
        5) 
            log_event "SESSION_END" "User exited Cerberus Main Menu" "INFO" 0
            exit 0 
            ;;
        *) 
            echo "Invalid option." 
            ;;
    esac
done