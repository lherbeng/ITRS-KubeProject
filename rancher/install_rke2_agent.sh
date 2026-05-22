#!/bin/bash
set -euxo pipefail

# Disable firewall
systemctl disable --now ufw || true

# Install required packages
apt update
apt install -y nfs-common open-iscsi curl openssh-client

# Define master node
MASTER_IP="10.140.7.5"
MASTER_USER="root"

# Create RKE2 config directory
mkdir -p /etc/rancher/rke2/

# Install RKE2 Agent
curl -sfL https://get.rke2.io | INSTALL_RKE2_TYPE="agent" sh -

# Enable service
systemctl enable rke2-agent.service

# Copy node token from master and skip SSH host authenticity prompt during automation
scp -o StrictHostKeyChecking=no \
${MASTER_USER}@${MASTER_IP}:/var/lib/rancher/rke2/server/node-token \
/etc/rancher/rke2/node-token

# Create config.yaml
cat <<EOF > /etc/rancher/rke2/config.yaml
server: https://${MASTER_IP}:9345
token: $(cat /etc/rancher/rke2/node-token)
EOF

# Start service
systemctl start rke2-agent.service

# Check status
systemctl status rke2-agent.service --no-pager

echo "RKE2 Agent installation completed."

# Official Website
# https://docs.rke2.io/install/quickstart#linux-agent-worker-node-installation
