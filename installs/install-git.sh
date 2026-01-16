#!/bin/bash
# install-git.sh
# This script installs Git.

set -e

if [[ "$EUID" -ne 0 ]]; then
  echo "Please run as root (using sudo)"
  exit 1
fi

echo "Updating package lists..."
apt-get update

echo "Installing git..."
apt-get install -y git

echo "Git has been installed successfully!"
