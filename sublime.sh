#!/usr/bin/env bash

# Detect OS
if [[ "$OSTYPE" == "darwin"* ]]; then
    OS_TYPE="macOS"
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    OS_TYPE="Linux"
fi

# Check if Homebrew's bin exists and if it's not already in the PATH (macOS only)
if [ "$OS_TYPE" = "macOS" ] && [ -x "/opt/homebrew/bin/brew" ] && [[ ":$PATH:" != *":/opt/homebrew/bin:"* ]]; then
    export PATH="/opt/homebrew/bin:$PATH"
fi

# Check if Sublime Text is installed
if ! command -v subl &>/dev/null; then
    echo "Sublime Text is not installed. Skipping Sublime Text setup..."
    exit 0
fi

# Set config paths based on OS
if [ "$OS_TYPE" = "macOS" ]; then
    CONFIG_PATH="$HOME/Library/Application Support/Sublime Text/Installed Packages"
    USER_PACKAGES_DIR="$HOME/Library/Application Support/Sublime Text/Packages/User"
    KEYMAP_FILENAME="Default (OSX).sublime-keymap"
elif [ "$OS_TYPE" = "Linux" ]; then
    CONFIG_PATH="$HOME/.config/sublime-text/Installed Packages"
    USER_PACKAGES_DIR="$HOME/.config/sublime-text/Packages/User"
    KEYMAP_FILENAME="Default (Linux).sublime-keymap"
fi

# Check if 'subl' command is available
if ! command -v subl &>/dev/null; then
    echo "'subl' command not found. Creating symlink for Sublime Text."

    # Creating the symlink for Sublime Text's 'subl' command-line tool
    if [ "$OS_TYPE" = "macOS" ]; then
        # Ensure Sublime Text is installed in the Applications folder
        if [ -e "/Applications/Sublime Text.app/Contents/SharedSupport/bin/subl" ]; then
            # Create the symlink in /usr/local/bin
            ln -s "/Applications/Sublime Text.app/Contents/SharedSupport/bin/subl" /usr/local/bin/subl
            echo "Symlink created successfully."
        else
            echo "Sublime Text application not found in the expected location. Please ensure it's installed in the Applications folder."
        fi
    else
        echo "Please ensure Sublime Text is installed. You can install it via: sudo snap install sublime-text --classic"
    fi
else
    echo "'subl' command is already available."
fi

# Create necessary directories
mkdir -p "$CONFIG_PATH"
mkdir -p "$USER_PACKAGES_DIR"

# Open Sublime Text to create necessary folders
subl .

MAX_WAIT=30 # Maximum number of seconds to wait
waited=0

until [[ -d "$CONFIG_PATH" ]] || [[ $waited -ge $MAX_WAIT ]]; do
    echo "Waiting for Sublime Text to initialize..."
    sleep 1
    ((waited++))
done

if [[ -d "$CONFIG_PATH" ]]; then
    echo "Sublime Text initialized."
else
    echo "Sublime Text did not initialize within $MAX_WAIT seconds."
    exit 1
fi

# Quit Sublime after folders are created
if [ "$OS_TYPE" = "macOS" ]; then
    osascript -e 'quit app "Sublime Text"'
else
    pkill -f "sublime_text" || true
fi

# Install Latest version of Package Control
curl -L -o "$CONFIG_PATH/Package Control.sublime-package" "https://github.com/wbond/package_control/releases/latest/download/Package.Control.sublime-package"

# Copy packages that should be installed
cp "settings/Package Control.sublime-settings" "$USER_PACKAGES_DIR/Package Control.sublime-settings"

# Open Sublime Text to install packages
echo "Opening Sublime to automatically install packages"
subl .
echo "Press Enter after Packages are all installed..."
read

# Quit Sublime after packages are installed
if [ "$OS_TYPE" = "macOS" ]; then
    osascript -e 'quit app "Sublime Text"'
else
    pkill -f "sublime_text" || true
fi

# Copy custom settings and configurations
cp "settings/Preferences.sublime-settings" "$USER_PACKAGES_DIR/Preferences.sublime-settings"
cp "settings/$KEYMAP_FILENAME" "$USER_PACKAGES_DIR/$KEYMAP_FILENAME" 2>/dev/null || echo "Keymap file not found, skipping..."
cp "settings/Material-Theme-Darker.sublime-theme" "$USER_PACKAGES_DIR/Material-Theme-Darker.sublime-theme" 2>/dev/null || echo "Theme file not found, skipping..."
cp "settings/JsPrettier.sublime-settings" "$USER_PACKAGES_DIR/JsPrettier.sublime-settings"
cp "settings/SublimeLinter.sublime-settings" "$USER_PACKAGES_DIR/SublimeLinter.sublime-settings"

# Copy custom build systems
cp "settings/Python-3.sublime-build" "$USER_PACKAGES_DIR/Python-3.sublime-build"

# Create Python tutorial environment build configuration
echo "{
  \"cmd\": [\"$HOME/tutorial/bin/python\", \"-u\", \"\$file\"],
  \"file_regex\": \"^[ ]*File \\\"(...*?)\\\", line ([0-9]*)\",
  \"quiet\": true
}" >"$USER_PACKAGES_DIR/Python-Tut-Env.sublime-build"

echo "Custom Sublime Text settings and packages have been copied."

# Open Sublime Text to check for errors
subl .
if [ "$OS_TYPE" = "macOS" ]; then
    echo "You can view potential Sublime Text errors by pressing Ctrl + backtick"
else
    echo "You can view potential Sublime Text errors in the Sublime Console (View > Show Console)"
fi
echo "If there are no errors, activate your Sublime license (if applicable)."
echo "Press enter to continue..."
read
