#!/bin/bash

set -e  # Exit immediately if a command exits with a non-zero status

# Define variables
KEYRING_PATH="/usr/share/keyrings/nginx-archive-keyring.gpg"
NGINX_SIGNING_KEY_URL="https://nginx.org/keys/nginx_signing.key"
NGINX_REPO_LIST="/etc/apt/sources.list.d/nginx.list"
PREFERENCES_FILE="/etc/apt/preferences.d/99nginx"

# Ensure the script is run as root
if [ "$EUID" -ne 0 ]; then
    echo "Please run this script as root or using sudo"
    exit 1
fi

# Install prerequisites
echo "Installing prerequisites..."
apt update && apt install -y curl gnupg2 ca-certificates lsb-release ubuntu-keyring

# Import the NGINX signing key
echo "Importing the NGINX signing key..."
curl -fsSL $NGINX_SIGNING_KEY_URL | gpg --dearmor > $KEYRING_PATH
chmod 644 $KEYRING_PATH

echo "Verifying the imported key..."
gpg --dry-run --quiet --no-keyring --import --import-options import-show $KEYRING_PATH | grep "573BFD6B3D8FBC641079A6ABABF5BD827BD9BF62"
if [ $? -ne 0 ]; then
    echo "The key fingerprint does not match. Exiting..."
    exit 1
fi

# Set up the APT repository
echo "Setting up the APT repository..."
echo "deb [signed-by=$KEYRING_PATH] http://nginx.org/packages/ubuntu $(lsb_release -cs) nginx" > $NGINX_REPO_LIST

# Uncomment the following lines to enable the mainline repository instead
# echo "deb [signed-by=$KEYRING_PATH] http://nginx.org/packages/mainline/ubuntu $(lsb_release -cs) nginx" > $NGINX_REPO_LIST

# Set up repository pinning
echo "Setting up repository pinning..."
echo -e "Package: *\nPin: origin nginx.org\nPin: release o=nginx\nPin-Priority: 900\n" > $PREFERENCES_FILE

# Update package list and install NGINX
echo "Updating package list and installing NGINX..."
apt update && apt install -y nginx

# Enable nginx service on boot
echo "Enabling nginx service to start on boot..."
systemctl enable nginx

# Start nginx service
echo "Starting nginx service..."
systemctl start nginx

# verify nginx service status
echo "Checking nginx service status..."
systemctl status nginx --no-pager

# Verify installation
echo "Verifying NGINX installation..."
nginx -v
if [ $? -eq 0 ]; then
    echo "NGINX installation completed successfully."
else
    echo "There was an issue with the NGINX installation."
    exit 1
fi