#!/usr/bin/env bash
# install-node.sh
# Installs nvm (if missing) and installs/uses Node based on .nvmrc
# Safe, reproducible, and version-drift resistant

set -euo pipefail

# Do not run as root
if [ "${EUID:-$(id -u)}" -eq 0 ]; then
  echo "❌ Do not run this script as root"
  exit 1
fi

export NVM_DIR="$HOME/.nvm"

echo "▶ Checking nvm installation..."

# Install nvm if missing (uses latest stable nvm)
if [ ! -s "$NVM_DIR/nvm.sh" ]; then
  echo "▶ Installing nvm..."
  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/master/install.sh | bash
else
  echo "✓ nvm already installed"
fi

# Load nvm
# shellcheck source=/dev/null
. "$NVM_DIR/nvm.sh"

# Install Node according to .nvmrc
if [ -f ".nvmrc" ]; then
  echo "▶ Installing Node version from .nvmrc: $(cat .nvmrc)"
  nvm install
  nvm use
  nvm alias default "$(nvm current)"
else
  echo "⚠️  No .nvmrc found — installing latest LTS"
  nvm install --lts
  nvm use --lts
  nvm alias default lts/*
fi

echo ""
echo "✅ Installation complete"
echo "Node: $(node -v)"
echo "npm:  $(npm -v)"
echo "nvm:  $(nvm --version)"
echo "Active Node: $(nvm current)"

