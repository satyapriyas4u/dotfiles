#!/usr/bin/env bash
############################
# This script creates symlinks from the home directory to any desired dotfiles in $HOME/dotfiles
# Detects OS and runs appropriate installation scripts
# Checks for zsh before proceeding
############################

# Check if zsh is installed
if ! command -v zsh &>/dev/null; then
    echo "Error: zsh is not installed."
    echo ""
    echo "Please install zsh first:"
    echo "  On macOS: brew install zsh"
    echo "  On Ubuntu/Debian: sudo apt-get install zsh"
    echo ""
    exit 1
fi

if [ -f /etc/os-release ]; then
  . /etc/os-release
  echo "$NAME $VERSION"
fi


echo "zsh is installed. Proceeding with installation..."

# Detect OS
if [[ "$OSTYPE" == "darwin"* ]]; then
    OS_TYPE="macOS"
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    OS_TYPE="Linux"
else
    echo "Error: Unsupported operating system."
    exit 1
fi

echo "Detected OS: $OS_TYPE"

# dotfiles directory
dotfiledir="${HOME}/dotfiles"

# list of files/folders to symlink in ${homedir}
files=(zshrc zprofile zprompt bashrc bash_profile bash_prompt aliases private)

# change to the dotfiles directory
echo "Changing to the ${dotfiledir} directory"
cd "${dotfiledir}" || exit

# create symlinks (will overwrite old dotfiles)
for file in "${files[@]}"; do
    echo "Creating symlink to $file in home directory."
    ln -sf "${dotfiledir}/.${file}" "${HOME}/.${file}"
done

# create symlinks for configs (will overwrite old configs)
mkdir -p "${HOME}/.config/ruff"
ln -sf "${dotfiledir}/settings/ruff.toml" "${HOME}/.config/ruff/ruff.toml"

# Run OS-specific scripts
if [ "$OS_TYPE" = "macOS" ]; then
    echo "Running macOS installation scripts..."
    ./macOS.sh
    ./brew.sh
elif [ "$OS_TYPE" = "Linux" ]; then
    echo "Running Ubuntu/Linux installation scripts..."
    ./linux-packages.sh
    ./ubuntu.sh
fi

# Run VS Code Script
./vscode.sh

# Run the Sublime Script
./sublime.sh

echo "Installation Complete!"
