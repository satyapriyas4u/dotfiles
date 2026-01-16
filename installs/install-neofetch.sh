#!/bin/bash
# install-neofetch.sh
# This script installs neofetch.

set -e

if [[ "$EUID" -ne 0 ]]; then
  echo "Please run as root (using sudo)"
  exit 1
fi

echo "Updating package lists..."
apt-get update

echo "Installing neofetch..."
apt-get install -y neofetch

echo "neofetch has been installed successfully!"

