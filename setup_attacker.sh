#!/bin/bash
echo "🐺 Awakening Cerberus Operator Node..."

# 1. Update & Install Core Dependencies
apt-get update
apt-get install -y \
    curl git wget nano \
    iputils-ping net-tools iproute2 \
    nmap dsniff tcpdump \
    lynis jq openssh-client

# 2. Install Gum (The UI Engine)
if ! command -v gum &> /dev/null; then
    echo "📦 Installing Gum UI..."
    mkdir -p /etc/apt/keyrings
    curl -fsSL https://repo.charm.sh/apt/gpg.key | gpg --dearmor -o /etc/apt/keyrings/charm.gpg
    echo "deb [signed-by=/etc/apt/keyrings/charm.gpg] https://repo.charm.sh/apt/ * *" | tee /etc/apt/sources.list.d/charm.list
    apt-get update && apt-get install -y gum
fi

# 3. Fix Permissions
chmod +x /app/cerberus.sh
chmod +x /app/modules/*.sh 2>/dev/null

echo "✅ Cerberus is ready. Run: /app/cerberus.sh"