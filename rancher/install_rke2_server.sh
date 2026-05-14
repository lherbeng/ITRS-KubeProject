#!/bin/bash
set -x  # Enable debugging

# Stop Firewall
systemctl disable --now ufw

# Run updates and upgrade and install packages
apt update
apt install nfs-common open-iscsi -y
apt upgrade -y

# Automatic removal of unnecessary packages
apt autoremove -y

# Install RKE2 server
curl -sfL https://get.rke2.io | INSTALL_RKE2_TYPE=server sh -

# Enable and start RKE2 Server service
systemctl enable rke2-server.service
systemctl start rke2-server.service

# Wait until RKE2 service is active
while ! systemctl is-active --quiet rke2-server.service; do
    echo "Waiting for RKE2 service to be active..."
    sleep 5
done
echo "RKE2 service is active."

# Wait until Kubernetes API server is fully ready
echo "Waiting for Kubernetes API to become available..."
until /var/lib/rancher/rke2/bin/kubectl --kubeconfig=/etc/rancher/rke2/rke2.yaml get node &>/dev/null; do
    sleep 5
    echo "Still waiting for Kubernetes API..."
done
echo "✅ Kubernetes API is ready."

# Patch the kubeconfig: Replace 127.0.0.1 with real IP
MASTER_IP=$(hostname -I | awk '{print $1}')
sed -i "s/127.0.0.1/${MASTER_IP}/g" /etc/rancher/rke2/rke2.yaml

# Download the latest stable version of kubectl
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"

# Move kubectl to /usr/local/bin and make it executable
sudo mv kubectl /usr/local/bin/kubectl
sudo chmod +x /usr/local/bin/kubectl

# Set permission on kubeconfig
sudo chmod 644 /etc/rancher/rke2/rke2.yaml

# Export KUBECONFIG for current session
export KUBECONFIG=/etc/rancher/rke2/rke2.yaml

# Append KUBECONFIG to .bashrc (for future sessions)
echo 'export KUBECONFIG=/etc/rancher/rke2/rke2.yaml' >> ~/.bashrc
. ~/.bashrc

# Check if kubectl works
kubectl get nodes || echo "❌ kubectl failed."
kubectl --kubeconfig=/etc/rancher/rke2/rke2.yaml get node -o wide || echo "❌ explicit kubeconfig failed."

# Get server IP address Of RKE2 Server
ip addr | grep inet

# Get Server token and copy it somewhere
cat /var/lib/rancher/rke2/server/node-token
