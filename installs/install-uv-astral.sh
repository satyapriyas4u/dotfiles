#!/bin/bash
# install-uv-astral.sh
# This script ensures that curl is installed and then downloads and executes the uv-astral installation script.
# Save this file and run it with sudo: sudo ./install-uv-astral.sh

# Exit immediately if any command fails.
set -e

# Check if the script is run as root.
if [[ "$EUID" -ne 0 ]]; then
echo "This script must be run as root. Please run using sudo."
exit 1
fi

# Check if curl is installed; if not, install it.
if ! command -v curl &>/dev/null; then
echo "curl is not installed. Installing curl..."
apt-get update
apt-get install -y curl
else
echo "curl is already installed."
fi

# Download and execute the uv-astral installation script.
echo "Installing uv-astral..."
curl -LsSf https://astral.sh/uv/install.sh | sh

echo "uv-astral installation completed successfully!"
