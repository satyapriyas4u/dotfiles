#!/bin/bash

# Check for root privileges
if [ "$EUID" -ne 0 ]; then
  echo "This script requires root privileges."
  echo "Please enter your password to proceed."
  
  # Request sudo privileges
  if sudo -v; then
    echo "Sudo access granted. Proceeding..."
  else
    echo "Failed to gain sudo access. Exiting..."
    exit 1
  fi
fi

echo "Starting system update and upgrade..."

# Check if nala is available, otherwise use apt
if command -v nala &> /dev/null; then
  PKG_MANAGER="nala"
else
  PKG_MANAGER="apt"
fi

echo "Using $PKG_MANAGER as package manager"

# Update package lists
echo "Updating package lists..."
sudo $PKG_MANAGER update

# Upgrade packages
echo "Upgrading installed packages..."
sudo $PKG_MANAGER upgrade -y

# Optional: clean up unnecessary packages
echo "Cleaning up unnecessary packages..."
sudo $PKG_MANAGER autoremove -y
if [ "$PKG_MANAGER" = "nala" ]; then
  sudo nala autopurge
fi

echo "System update and upgrade complete."

