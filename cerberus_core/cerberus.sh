#!/bin/bash
chmod +x /app/modules/*.sh 2>/dev/null

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
    echo " 3.  Network Traffic Analysis (tcpdump)"
    echo " 4.  RESET LAB TO VULNERABLE STATE"
    echo " 5.  Exit"
    echo "--------------------------------------------------------"
    read -p " Select Operation [1-5]: " choice

    case $choice in
        1) /app/modules/audit_scan.sh ;;
        2) /app/modules/harden_fix.sh ;;
        3) /app/modules/attack_arp.sh ;;
        4) 
           echo "[!] RESETTING CONFIGURATIONS..."
           sed -i '/net.ipv4.ip_forward/d' /etc/sysctl.conf
           # Kernel reset skipped in container
           sed -i '/minlen=12/d' /etc/pam.d/common-password
           echo " SYSTEM RESET TO VULNERABLE."
           read -p "Press Enter..." ;;
        5) exit 0 ;;
        *) echo "Invalid option." ;;
    esac
done
