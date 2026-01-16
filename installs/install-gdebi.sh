#!/bin/bash
# install-gdebi.sh
# This script installs the gdebi package.

# Exit immediately if a command exits with a non-zero status.
set -e

# Check if the script is run as root.
if [[ "$EUID" -ne 0 ]]; then
  echo "Please run as root (using sudo)"
  exit 1
fi

# Update package lists.
echo "Updating package lists..."
apt-get update

# Install gdebi.
echo "Installing gdebi..."
apt-get install -y gdebi

echo "gdebi has been installed successfully!"
