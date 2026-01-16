#!/bin/bash
# install-chrome.sh
# This script downloads and installs the latest stable version of Google Chrome.

# Exit immediately if a command exits with a non-zero status.
set -e

# Check if running as root. If not, exit with an error.
if [[ "$EUID" -ne 0 ]]; then
  echo "Please run as root (using sudo)!"
  exit 1
fi

# Update package lists
echo "Updating package lists..."
apt-get update

# Ensure that wget is installed.
if ! command -v wget &>/dev/null; then
  echo "wget not found. Installing wget..."
  apt-get install -y wget
fi

# Download the latest Google Chrome stable package to /tmp
CHROME_DEB="/tmp/google-chrome-stable_current_amd64.deb"
echo "Downloading Google Chrome stable package..."
wget -O "$CHROME_DEB" https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb

# Install the package. If there are dependency issues, fix them automatically.
echo "Installing Google Chrome..."
dpkg -i "$CHROME_DEB" || apt-get install -f -y

# Optional: Remove the downloaded .deb package
rm -f "$CHROME_DEB"

echo "Google Chrome stable has been installed successfully!"
