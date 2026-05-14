#!/bin/bash

# Run the official RKE2 uninstall script if it exists
if [ -f "/usr/local/bin/rke2-uninstall.sh" ]; then
    echo "Running default RKE2 uninstall script..."
    /usr/local/bin/rke2-uninstall.sh
else
    echo "Default rke2-uninstall.sh not found. Skipping..."
fi

# Additional cleanup steps
echo "Stopping RKE2 service..."
systemctl stop rke2-server
systemctl disable rke2-server

echo "Removing RKE2 files and data..."
rm -rf /etc/rancher/rke2
rm -rf /var/lib/rancher/rke2
rm -rf /usr/local/bin/kubectl

echo "Cleaning up KUBECONFIG..."
sed -i '/export KUBECONFIG/d' ~/.bashrc

echo "Reloading bashrc..."
source ~/.bashrc

if [ -f "/usr/local/bin/kubectl" ]; then
    echo "Removing kubectl symlink..."
    rm /usr/local/bin/kubectl
else
    echo "kubectl already removed 👍"
fi

echo "Running autoremove to clean up..."
apt autoremove -y

# Optional package removal (commented out)
# apt remove --purge -y nfs-common open-iscsi

echo "Uninstallation complete!"
