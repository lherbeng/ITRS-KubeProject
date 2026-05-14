#!/bin/bash
set -x  # Enable debugging

# Stop Firewall
systemctl disable --now ufw

# Run updates and install necessary packages
apt update
apt install nfs-common open-iscsi -y
apt upgrade -y

# Clean up unused packages
apt autoremove -y

# Define master node IP and user
MASTER_IP="192.168.1.5"
MASTER_USER="root"

# Install RKE2 Agent
curl -sfL https://get.rke2.io | INSTALL_RKE2_TYPE="agent" sh -

# Enable the RKE2 Agent service
systemctl enable rke2-agent.service

# Create config directory and fetch token from master
mkdir -p /etc/rancher/rke2/
scp ${MASTER_USER}@${MASTER_IP}:/var/lib/rancher/rke2/server/node-token /etc/rancher/rke2/node-token

# Create config.yaml for agent
TOKEN=$(cat /etc/rancher/rke2/node-token)
cat <<EOF > /etc/rancher/rke2/config.yaml
server: https://${MASTER_IP}:9345
token: ${TOKEN}
EOF

# Start the RKE2 Agent service
systemctl start rke2-agent.service

# Wait for agent to fully join
while ! systemctl is-active --quiet rke2-agent.service; do
    echo "Waiting for RKE2 Agent to be up..."
    sleep 5
done
echo "RKE2 Agent is running."

# Confirm with node IP
ip addr | grep inet