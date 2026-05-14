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

# Wait for RKE2 Server to be fully up
while ! systemctl is-active --quiet rke2-server.service; do
    echo "Waiting for RKE2 Server to be up..."
    sleep 5
done
echo "RKE2 Server is running."

# Download the latest stable version of kubectl
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"

# Move kubectl to /usr/local/bin and make it executable
sudo mv kubectl /usr/local/bin/kubectl
sudo chmod +x /usr/local/bin/kubectl

# Add kubectl config
# export KUBECONFIG=/etc/rancher/rke2/rke2.yaml
sudo chmod 644 /etc/rancher/rke2/rke2.yaml
kubectl get nodes

# Append KUBECONFIG to .bashrc (in case of interactive use)
echo 'export KUBECONFIG=/etc/rancher/rke2/rke2.yaml' >> ~/.bashrc
. ~/.bashrc

# Check if kubectl works, with --kubeconfig explicitly in case env is not propagated
kubectl --kubeconfig=/etc/rancher/rke2/rke2.yaml get node -o wide

# Get server IP address Of RKE2 Server
ip addr | grep inet

# Get Server token and copy it somewhere
cat /var/lib/rancher/rke2/server/node-token
