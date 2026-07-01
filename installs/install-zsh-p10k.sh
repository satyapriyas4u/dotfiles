#!/usr/bin/env bash
# Sets up Oh My Zsh + Powerlevel10k theme + MesloLGS NF fonts for zsh.
# Safe to re-run: each step checks if already done before acting.
#
# Flags:
#   --no-fonts   Skip font download (use on remote servers — VS Code renders
#                fonts from the local machine, so the remote doesn't need them).

set -e

SKIP_FONTS=false
for arg in "$@"; do
    [[ "$arg" == "--no-fonts" ]] && SKIP_FONTS=true
done

FONT_DIR="${HOME}/.local/share/fonts"
FONT_BASE="https://github.com/romkatv/powerlevel10k-media/raw/master"

# ── 1. Oh My Zsh ──────────────────────────────────────────────────────────────
if [ ! -d "${HOME}/.oh-my-zsh" ]; then
    echo "Installing Oh My Zsh..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
else
    echo "Oh My Zsh already installed. Skipping."
fi

# ── 2. Powerlevel10k theme ────────────────────────────────────────────────────
P10K_DIR="${ZSH_CUSTOM:-${HOME}/.oh-my-zsh/custom}/themes/powerlevel10k"
if [ ! -d "$P10K_DIR" ]; then
    echo "Cloning Powerlevel10k..."
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$P10K_DIR"
else
    echo "Powerlevel10k already installed at $P10K_DIR. Skipping."
fi

# ── 3. Completion plugins ─────────────────────────────────────────────────────
ZSH_CUSTOM="${ZSH_CUSTOM:-${HOME}/.oh-my-zsh/custom}"

clone_plugin() {
    local name="$1" url="$2"
    local dest="${ZSH_CUSTOM}/plugins/${name}"
    if [ ! -d "$dest" ]; then
        echo "Cloning ${name}..."
        git clone --depth=1 "$url" "$dest"
    else
        echo "${name} already installed. Skipping."
    fi
}

clone_plugin zsh-autosuggestions     https://github.com/zsh-users/zsh-autosuggestions
clone_plugin zsh-syntax-highlighting https://github.com/zsh-users/zsh-syntax-highlighting
clone_plugin zsh-completions         https://github.com/zsh-users/zsh-completions

# ── 4. MesloLGS NF fonts ─────────────────────────────────────────────────────
if [[ "$SKIP_FONTS" == true ]]; then
    echo "Skipping font installation (--no-fonts). VS Code renders fonts from local machine."
else
    echo "Installing MesloLGS NF fonts to ${FONT_DIR}..."
    mkdir -p "$FONT_DIR"

    declare -a FONTS=(
        "MesloLGS NF Regular.ttf"
        "MesloLGS NF Bold.ttf"
        "MesloLGS NF Italic.ttf"
        "MesloLGS NF Bold Italic.ttf"
    )

    for font in "${FONTS[@]}"; do
        dest="${FONT_DIR}/${font}"
        if [ -f "$dest" ]; then
            echo "  Already present: ${font}"
        else
            echo "  Downloading: ${font}"
            curl -fsSL "${FONT_BASE}/$(python3 -c "import urllib.parse,sys; print(urllib.parse.quote(sys.argv[1]))" "${font}")" \
                -o "$dest"
        fi
    done

    echo "Refreshing font cache..."
    fc-cache -f "$FONT_DIR"

    echo ""
    echo "Next steps:"
    echo "  1. Set your terminal font to 'MesloLGS NF' (Regular, size 12-13)."
    echo "     GNOME Terminal: Preferences → Profile → Text → Custom font"
fi

echo ""
echo "Done!"
echo ""
echo "Completion shortcuts:"
echo "  → (right arrow)  accept autosuggestion"
echo "  Ctrl+F           accept next word of suggestion"
echo "  Tab              open navigable completion menu (arrow keys to pick)"
