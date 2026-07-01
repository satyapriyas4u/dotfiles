#!/usr/bin/env bash
############################
# This script creates symlinks from the home directory to any desired dotfiles in $HOME/dotfiles
# Detects OS and runs appropriate installation scripts
# Checks for zsh before proceeding
#
# Flags:
#   --links-only   Only create symlinks; skip OS-specific install scripts.
#                  Use this on remote servers after running install-zsh-p10k.sh.
############################

LINKS_ONLY=false
for arg in "$@"; do
    [[ "$arg" == "--links-only" ]] && LINKS_ONLY=true
done

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
files=(zshrc zprofile zprompt bashrc bash_profile bash_prompt aliases private nanorc p10k.zsh)

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

# SSH config: use Include so ~/.ssh/config stays minimal
mkdir -p "${HOME}/.ssh"
chmod 700 "${HOME}/.ssh"
if ! grep -q "Include ~/dotfiles/ssh/config" "${HOME}/.ssh/config" 2>/dev/null; then
    # Prepend Include line — ssh reads it first, then the rest of the file
    tmpfile=$(mktemp)
    printf 'Include ~/dotfiles/ssh/config\n\n' | cat - "${HOME}/.ssh/config" 2>/dev/null > "$tmpfile"
    mv "$tmpfile" "${HOME}/.ssh/config"
    chmod 600 "${HOME}/.ssh/config"
    echo "Added SSH config Include for dotfiles/ssh/config"
fi

if [[ "$LINKS_ONLY" == true ]]; then
    echo "Installation Complete! (links-only mode — skipped OS scripts)"
    exit 0
fi

# autostart entries (Linux only — symlinks become inert on macOS)
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    mkdir -p "${HOME}/.config/autostart"
    for desktop in "${dotfiledir}"/settings/autostart/*.desktop; do
        [ -e "$desktop" ] || continue
        ln -sf "$desktop" "${HOME}/.config/autostart/$(basename "$desktop")"
    done

    # Create GNOME Templates so Nautilus shows New Document -> <type> for each
    mkdir -p "${HOME}/Templates"
    for tpl in "New Text File" "New Shell Script" "New Python Script" "New Markdown File"; do
        [ -e "${HOME}/Templates/${tpl}" ] || touch "${HOME}/Templates/${tpl}"
    done
fi

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

# Linux-only: restore GNOME extensions + targeted dconf settings from
# snapshots/ (terminal profile, interface tweaks, etc.). Skipped on macOS
# and when SKIP_RESTORE=1.
if [ "$OS_TYPE" = "Linux" ] && [ -z "${SKIP_RESTORE:-}" ] && [ -d "${dotfiledir}/snapshots" ]; then
    if [ -x "${dotfiledir}/installs/restore-gnome-extensions.sh" ]; then
        echo "Restoring GNOME extensions..."
        "${dotfiledir}/installs/restore-gnome-extensions.sh"
    fi
    if [ -x "${dotfiledir}/installs/restore-dconf.sh" ]; then
        echo "Restoring dconf settings..."
        "${dotfiledir}/installs/restore-dconf.sh"
    fi
fi

echo "Installation Complete!"
