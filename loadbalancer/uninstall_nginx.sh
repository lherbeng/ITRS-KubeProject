#!/bin/bash

set -e  # Exit immediately if a command exits with a non-zero status

# Ensure the script is run as root
if [ "$EUID" -ne 0 ]; then
    echo "Please run this script as root or using sudo"
    exit 1
fi

# Stop NGINX service if running
echo "Stopping NGINX service..."
systemctl stop nginx || echo "NGINX service is not running."

# Disable NGINX service
echo "Disabling NGINX service..."
systemctl disable nginx || echo "NGINX service was not enabled."

# Remove NGINX package
echo "Removing NGINX package..."
apt purge -y nginx nginx-common nginx-full || echo "NGINX packages are not installed."

# Remove additional dependencies no longer needed
echo "Removing unused dependencies..."
apt autoremove -y

# Delete NGINX configuration and log files
echo "Removing NGINX configuration and log files..."
rm -rf /etc/nginx /var/log/nginx

# Remove NGINX repository configuration
echo "Removing NGINX repository configuration..."
rm -f /etc/apt/sources.list.d/nginx.list

# Remove NGINX signing key
echo "Removing NGINX signing key..."
rm -f /usr/share/keyrings/nginx-archive-keyring.gpg

# Update package list
echo "Updating package list..."
apt update

# Confirm completion
echo "NGINX has been successfully uninstalled."
