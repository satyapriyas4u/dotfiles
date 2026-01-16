#!/bin/bash
# install-nala.sh
# This script installs nala, an apt front-end.

set -e

if [[ "$EUID" -ne 0 ]]; then
  echo "Please run as root (using sudo)"
  exit 1
fi

echo "Updating package lists..."
apt-get update

echo "Installing nala..."
apt-get install -y nala

echo "nala has been installed successfully!"

