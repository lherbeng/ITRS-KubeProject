#!/bin/bash

set -euxo pipefail

# Disable firewall
systemctl disable --now ufw

# Update package lists
apt update

# Install required packages
apt install -y nfs-common open-iscsi curl

# Upgrade installed packages
DEBIAN_FRONTEND=noninteractive apt upgrade -y

# Remove unnecessary packages
apt autoremove -y

# Install RKE2 server
curl -sfL https://get.rke2.io | INSTALL_RKE2_TYPE=server sh -

# Enable and start RKE2 server
systemctl enable rke2-server.service
systemctl start rke2-server.service

# Wait until RKE2 service is active
while ! systemctl is-active --quiet rke2-server.service; do
    echo "Waiting for RKE2 service to become active..."
    sleep 5
done

echo "✅ RKE2 service is active."

# Wait until Kubernetes API is ready
echo "Waiting for Kubernetes API..."

until /var/lib/rancher/rke2/bin/kubectl \
    --kubeconfig=/etc/rancher/rke2/rke2.yaml \
    get nodes &>/dev/null
do
    echo "Still waiting for Kubernetes API..."
    sleep 5
done

echo "✅ Kubernetes API is ready."

# Get server IP address
MASTER_IP=$(hostname -I | awk '{print $1}')

# Replace localhost with actual server IP
sed -i "s/127.0.0.1/${MASTER_IP}/g" \
/etc/rancher/rke2/rke2.yaml

# Create kubectl symlink
ln -sf /var/lib/rancher/rke2/bin/kubectl /usr/local/bin/kubectl

# Create kube config directory
mkdir -p /root/.kube

# Copy kubeconfig permanently
cp /etc/rancher/rke2/rke2.yaml /root/.kube/config

# Set permissions
chmod 600 /root/.kube/config
chmod 644 /etc/rancher/rke2/rke2.yaml

# Export KUBECONFIG globally for future shells
cat <<EOF >/etc/profile.d/rke2.sh
export KUBECONFIG=/root/.kube/config
EOF

chmod +x /etc/profile.d/rke2.sh

# Load KUBECONFIG in current shell
export KUBECONFIG=/root/.kube/config

# Verify kubectl access
kubectl get nodes
kubectl get nodes -o wide

# Display server IP addresses
echo "================ SERVER IP ADDRESS ================"
ip addr | grep inet

# Display RKE2 node token
echo "================ RKE2 NODE TOKEN ================"
cat /var/lib/rancher/rke2/server/node-token

# Check if reboot is required
if [ -f /var/run/reboot-required ]; then
    echo "⚠️ Reboot required."
fi

echo "✅ RKE2 server installation completed successfully."