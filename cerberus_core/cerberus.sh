#!/bin/bash

# ============================================================
# PROJECT CERBERUS: Automated Purple Team Framework
# ============================================================

# --- 1. SETUP & CONFIG ---
BASE_DIR="/app"
MODULES_DIR="$BASE_DIR/modules"
CONFIG_FILE="$BASE_DIR/config/targets.conf"
TIMESTAMP=$(date +%F_%H-%M)

# Source the configuration
if [ -f "$CONFIG_FILE" ]; then
    source "$CONFIG_FILE"
else
    # Fallback default if config is missing
    TARGET_IP="172.20.0.20"
    REPORT_DIR="/app/reports"
fi

LOG_FILE="$REPORT_DIR/session_$TIMESTAMP.json"

# --- 2. UI FUNCTIONS ---
show_banner() {
    clear
    gum style \
        --foreground 212 --border-foreground 212 --border double \
        --align center --width 60 --margin "1 2" \
        "🐺 PROJECT CERBERUS 🐺" \
        "Audit | Attack | Harden"
    
    echo "   🎯 LOCKED TARGET: $TARGET_IP"
    echo "   📂 LOGGING TO: $LOG_FILE"
    echo ""
}

# --- 3. EXECUTION ENGINE ---
run_module() {
    local script_name=$1
    local script_path="$MODULES_DIR/$script_name"

    if [ ! -f "$script_path" ]; then
        gum style --foreground 196 "❌ Error: Module $script_name not found!"
        sleep 2
        return
    fi

    gum confirm "Execute $script_name on $TARGET_IP?" && {
        gum spin --spinner dot --title "Cerberus is engaging..." -- sleep 1.5
        clear 
        show_banner
        # RUN THE MODULE
        /bin/bash "$script_path" "$TARGET_IP" "$LOG_FILE"
        
        echo ""
        gum style --foreground 82 "✅ Module Execution Complete."
        read -r -p "Press Enter to return to Command Center..."
    }
}

# --- 4. MAIN LOOP ---
mkdir -p "$REPORT_DIR"

while true; do
    show_banner

    ACTION=$(gum choose \
        "1. 🔍 Scan & Audit (Lynis/Nmap)" \
        "2. ⚔️  Attack: ARP Poisoning (MITM)" \
        "3. 🛡️  Harden: Apply Fixes" \
        "4. 📊 View Reports" \
        "5. 🚪 Disconnect")

    case "$ACTION" in
        "1. 🔍 Scan & Audit (Lynis/Nmap)")
            run_module "audit_scan.sh"
            ;;
        "2. ⚔️  Attack: ARP Poisoning (MITM)")
            run_module "attack_arp.sh"
            ;;
        "3. 🛡️  Harden: Apply Fixes")
            run_module "harden_fix.sh"
            ;;
        "4. 📊 View Reports")
            echo "--- Latest Logs ---"
            ls -lt "$REPORT_DIR" | head -n 5
            read -r -p "Press Enter..."
            ;;
        "5. 🚪 Disconnect")
            echo "🐺 Cerberus sleeping..."
            exit 0
            ;;
    esac
done
