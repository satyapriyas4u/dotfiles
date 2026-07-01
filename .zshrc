# Enable Powerlevel10k instant prompt. Must stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Path to your Oh My Zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Theme
ZSH_THEME="powerlevel10k/powerlevel10k"

# Which plugins would you like to load?
plugins=(
  git
  zsh-autosuggestions       # fish-like ghost suggestions from history (→ to accept)
  zsh-syntax-highlighting   # red=invalid command, green=valid as you type
  zsh-completions           # extended tab-completion for 300+ commands
)

# zsh-completions must be added to fpath before compinit runs (oh-my-zsh calls it)
fpath+="${ZSH_CUSTOM:-${ZSH}/custom}/plugins/zsh-completions/src"

# Must be set before oh-my-zsh sources zsh-syntax-highlighting
ZSH_HIGHLIGHT_HIGHLIGHTERS=(main brackets)

source $ZSH/oh-my-zsh.sh

# ── Syntax highlighting colors (set after oh-my-zsh) ──────────────────────────
# "command"    = external binaries: touch, mkdir, git, python3, etc.
# "builtin"    = shell builtins:    source, cd, echo, export, alias, etc.
# "precommand" = command prefixes:  sudo, env, nohup, time
# "function"   = shell functions:   yt_init and anything you define
# "alias"      = your aliases
# "unknown-token" = red — mistyped or not-found command
ZSH_HIGHLIGHT_STYLES[command]='fg=green,bold'
ZSH_HIGHLIGHT_STYLES[builtin]='fg=green,bold'
ZSH_HIGHLIGHT_STYLES[function]='fg=green,bold'
ZSH_HIGHLIGHT_STYLES[alias]='fg=green,bold'
ZSH_HIGHLIGHT_STYLES[precommand]='fg=green,bold'        # sudo, env, nohup
ZSH_HIGHLIGHT_STYLES[unknown-token]='fg=red,bold'
ZSH_HIGHLIGHT_STYLES[reserved-word]='fg=cyan,bold'      # if for while do done
ZSH_HIGHLIGHT_STYLES[single-quoted-argument]='fg=yellow'
ZSH_HIGHLIGHT_STYLES[double-quoted-argument]='fg=yellow'
ZSH_HIGHLIGHT_STYLES[dollar-quoted-argument]='fg=yellow'
ZSH_HIGHLIGHT_STYLES[single-hyphen-option]='fg=magenta' # -v, -rf
ZSH_HIGHLIGHT_STYLES[double-hyphen-option]='fg=magenta' # --verbose
ZSH_HIGHLIGHT_STYLES[path]='fg=cyan,underline'
ZSH_HIGHLIGHT_STYLES[globbing]='fg=blue,bold'           # *.txt, **/*
ZSH_HIGHLIGHT_STYLES[redirection]='fg=blue,bold'        # > >> | 2>&1
ZSH_HIGHLIGHT_STYLES[commandseparator]='fg=blue,bold'   # ; && ||
ZSH_HIGHLIGHT_STYLES[comment]='fg=245'                  # # comment text

# Tab-completion: navigable menu with arrow keys + case-insensitive matching
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}' 'r:|=*' 'l:|=* r:|=*'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"  # color completions like ls

# Don't ask if user is sure when running rm with wildcards (like bash)
setopt rmstarsilent

# If wildcard pattern has no matches, return an empty string (like bash)
setopt no_nomatch

# Specify the history file and its sizes
export HISTFILE=~/.zsh_history
export HISTSIZE=10000
export SAVEHIST=10000

# These options improve history behavior across sessions
setopt SHARE_HISTORY          # Share command history across all open sessions
setopt APPEND_HISTORY         # Append history rather than overwriting it
setopt HIST_REDUCE_BLANKS     # Remove superfluous blanks from each command line being added to the history list
setopt HIST_IGNORE_SPACE      # Ignore commands that start with a space (for secret or experimental commands)
setopt HIST_EXPIRE_DUPS_FIRST # Expire duplicates first when trimming history

# Load dotfiles:
for file in ~/.{aliases,private}; do
    [ -r "$file" ] && [ -f "$file" ] && source "$file"
done
unset file

# YouTube script initialization
# Usage:
#   yt_init              # init current dir
#   yt_init project_name # create ./project_name, set it up, but stay where you are
yt_init() {
  local template="$HOME/dotfiles/prompts/AGENTS.md"
  local template_dir="$HOME/My_Drive/YouTube/Youtube-Tutorial-Template"
  local gitignore_stack="${GITIGNORE_STACK:-python,macos,visualstudiocode,dotenv}"
  local gitignore_url="https://www.toptal.com/developers/gitignore/api/${gitignore_stack}"
  local orig="$PWD"
  local target="."
  local dir

  [[ -f "$template" ]] || { echo "Template not found: $template"; return 1; }

  if [[ $# -eq 1 ]]; then
    target="$1"

    if [[ -d "$target" ]] && [[ -n "$(ls -A "$target" 2>/dev/null)" ]]; then
      echo "❌ Error: Directory '$target' already exists and is not empty."
      echo "   Please use an empty directory or remove existing contents."
      return 1
    fi

    uv init "$target" || return
  elif [[ $# -eq 0 ]]; then

    if [[ -n "$(ls -A . 2>/dev/null)" ]]; then
      echo "❌ Error: Current directory is not empty."
      echo "   Please run yt_init from an empty directory or specify a new directory name."
      return 1
    fi

    uv init || return
  else
    echo "Usage: yt_init [project_name]"
    return 1
  fi

  dir="$orig"; [[ "$target" == "." ]] || dir="$orig/$target"

  if command -v curl >/dev/null; then
    curl -fsSL "$gitignore_url" -o "$dir/.gitignore" \
      || echo "⚠️  Could not fetch .gitignore; keeping uv's default."
  else
    echo "⚠️  curl not found; keeping uv's default .gitignore."
  fi

  mkdir -p "$dir/.github"
  mkdir -p "$dir/.claude/commands"
  mkdir -p "$dir/reference-examples"
  cp -f "$template" "$dir/AGENTS.md"
  : > "$dir/s.txt"
  : > "$dir/sandbox.txt"
  : > "$dir/sandbox.py"
  : > "$dir/snippets.txt"

  if [[ -d "$template_dir/.claude/commands" ]]; then
    cp -f "$template_dir/.claude/commands/"* "$dir/.claude/commands/" 2>/dev/null \
      && echo "✅ Copied Claude commands from template." \
      || echo "⚠️  Could not copy Claude commands (directory may be empty)."
  else
    echo "⚠️  Template Claude commands directory not found."
  fi

  if [[ -f "$template_dir/CLAUDE.md" ]]; then
    cp -f "$template_dir/CLAUDE.md" "$dir/CLAUDE.md" \
      && echo "✅ Copied CLAUDE.md from template." \
      || echo "⚠️  Could not copy CLAUDE.md."
  else
    echo "⚠️  Template CLAUDE.md not found."
  fi

  if [[ -d "$template_dir/reference-examples" ]]; then
    cp -f "$template_dir/reference-examples/"* "$dir/reference-examples/" 2>/dev/null \
      && echo "✅ Copied reference examples from template." \
      || echo "⚠️  Could not copy reference examples (directory may be empty)."
  else
    echo "⚠️  Template reference examples directory not found."
  fi

  ( cd "$dir" && uv venv ) || return

  if command -v git >/dev/null; then
    git -C "$dir" add -A
    if git -C "$dir" commit -m "Initial Commit"; then
      echo "✅ Created initial Git commit."
    else
      echo "ℹ️  Git commit skipped/failed (possibly re-ran yt_init or git not configured)."
    fi
  else
    echo "⚠️  git not found; skipping initial commit."
  fi

  echo "✅ Project ready at $dir"
}


# SSH agent — local desktop only.
# On remote servers VS Code Remote SSH forwards your local agent automatically
# via SSH_AUTH_SOCK, so no agent needs to be started there.
# XDG_RUNTIME_DIR is only set by the desktop session (pam_systemd); skip on servers.
if [[ -n "${XDG_RUNTIME_DIR:-}" ]]; then
    export SSH_AUTH_SOCK="$XDG_RUNTIME_DIR/ssh-agent.socket"
    if [ ! -S "$SSH_AUTH_SOCK" ]; then
        eval "$(ssh-agent -a "$SSH_AUTH_SOCK")" > /dev/null
    fi
    if ! ssh-add -l >/dev/null 2>&1; then
        for key in ~/.ssh/git ~/.ssh/id_ed25519 ~/.ssh/id_ed25519_aws; do
            [ -f "$key" ] && ssh-add "$key"
        done
    fi
fi

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
