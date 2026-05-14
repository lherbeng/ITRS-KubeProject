#!/bin/bash
set -x  # Enable debug output

echo "Stopping RKE2 Agent service..."
systemctl stop rke2-agent

echo "Disabling RKE2 Agent service..."
systemctl disable rke2-agent

echo "Removing RKE2 binaries and systemd files..."
rm -f /usr/local/bin/rke2*
rm -f /etc/systemd/system/rke2-agent.service
rm -f /etc/systemd/system/rke2-agent.env
rm -rf /etc/systemd/system/rke2-agent.service.d

echo "Reloading systemd daemon..."
systemctl daemon-reload

echo "Deleting RKE2 config and data directories..."
rm -rf /etc/rancher/rke2
rm -rf /var/lib/rancher/rke2
rm -rf /etc/rancher/node

echo "RKE2 Agent node has been fully uninstalled and cleaned up."