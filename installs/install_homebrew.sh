#!/bin/bash

echo "Do you want to install Homebrew?"
read -p "Enter 'Yes' or 'No': " response

if [ "$response" = "Yes" ] || [ "$response" = "Y" ] || [ "$response" = "y" ]; then
  echo "Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  echo "Homebrew installation complete."
  
  # Add Homebrew to PATH
  echo "Adding Homebrew to PATH..."
  eval "$(/opt/homebrew/bin/brew shellenv)"
  
  # Add to shell configuration files for persistence
  if [[ "$SHELL" == *"zsh"* ]]; then
    echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zshrc
    source ~/.zshrc
    echo "Added to ~/.zshrc"
  elif [[ "$SHELL" == *"bash"* ]]; then
    echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.bash_profile
    source ~/.bash_profile
    echo "Added to ~/.bash_profile"
  fi
else
  echo "Homebrew installation cancelled."
  exit 0
fi