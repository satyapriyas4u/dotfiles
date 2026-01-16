#!/bin/bash

set -e  # Exit immediately if a command exits with a non-zero status

# Ensure the script is run with sudo
if [[ "$EUID" -ne 0 ]]; then
  echo "Please run this script with sudo:"
  echo "  sudo $0"
  exit 1
fi

echo "Updating package list..."
apt-get update

echo "Installing curl..."
apt-get install -y curl

echo "Adding Ookla Speedtest repository..."
curl -s https://packagecloud.io/install/repositories/ookla/speedtest-cli/script.deb.sh | bash

echo "Installing speedtest..."
apt-get install -y speedtest

echo "Speedtest installation completed successfully."

