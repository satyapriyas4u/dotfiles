# Dotfiles — Satyapriya

Personal development environment for Ubuntu and macOS. Includes zsh shell config,
Powerlevel10k prompt, syntax highlighting, VS Code settings, and scripts to replicate
the full setup on a new machine or remote server in one command.

> **Warning:** These configs are personalized to my workflow. Fork and adapt before running — they will overwrite your existing dotfiles.

---

## Table of Contents

- [Fresh Ubuntu Desktop Setup](#fresh-ubuntu-desktop-setup)
- [Fresh macOS Setup](#fresh-macos-setup)
- [Remote Server Setup (VS Code Remote SSH)](#remote-server-setup)
- [Daily Workflow](#daily-workflow)
- [Shell: zsh + Powerlevel10k](#shell-zsh--powerlevel10k)
- [VS Code Integrated Terminal](#vs-code-integrated-terminal)
- [Aliases Reference](#aliases-reference)
- [File Reference](#file-reference)
- [Troubleshooting](#troubleshooting)

---

## Fresh Ubuntu Desktop Setup

Run these commands in order on a brand-new Ubuntu machine.

### 1. Clone the repo

```bash
git clone https://github.com/satyapriyas4u/dotfiles.git ~/dotfiles
cd ~/dotfiles
```

### 2. Install zsh + Powerlevel10k + fonts

```bash
./installs/install-zsh-p10k.sh
```

This installs:
- Oh My Zsh
- Powerlevel10k theme
- `zsh-autosuggestions`, `zsh-syntax-highlighting`, `zsh-completions` plugins
- MesloLGS NF fonts (required for prompt icons)

After it finishes, **set your terminal font to `MesloLGS NF`**:
- GNOME Terminal → Preferences → your profile → Text → Custom font → `MesloLGS NF` size 13

### 3. Set up third-party apt repos (before the full install)

Some packages (Chrome, VS Code, AnyDesk, etc.) need their repos added first.
See [`snapshots/THIRD-PARTY-REPOS.md`](snapshots/THIRD-PARTY-REPOS.md) for the full list, then run:

```bash
./installs/setup-third-party-repos.sh
```

### 4. Run the main installer

```bash
./install.sh
```

This will:
- Create symlinks: `~/.zshrc`, `~/.p10k.zsh`, `~/.aliases`, `~/.bashrc`, etc.
- Wire in `~/dotfiles/ssh/config` via an `Include` line in `~/.ssh/config`
- Install Linux packages (`linux-packages.sh`)
- Configure git, gh CLI, and default shell (`ubuntu.sh`)
- Install VS Code and Sublime Text
- Restore apt packages, snap packages, flatpak apps, VS Code extensions, GNOME extensions, and dconf settings from `snapshots/`

> Skip snapshot restore (e.g. on a dev-only machine):
> ```bash
> SKIP_RESTORE=1 ./install.sh
> ```

### 5. After install

```bash
# Restart terminal (or log out and back in) for zsh to become the default shell
exec zsh

# Verify prompt looks correct (icons, colors, git status)
cd ~/dotfiles && git status
```

If icons look like boxes or question marks, the terminal font is not set to `MesloLGS NF` — go back to step 2.

---

## Fresh macOS Setup

```bash
git clone https://github.com/satyapriyas4u/dotfiles.git ~/dotfiles
cd ~/dotfiles
./installs/install-zsh-p10k.sh
./install.sh
```

`install.sh` detects macOS and runs `macOS.sh` + `brew.sh` instead of the Linux scripts.

---

## Remote Server Setup

Replicates the zsh + Powerlevel10k shell experience on any server you connect to via VS Code Remote SSH. Fonts are **not** installed on the server — VS Code renders them from your local machine.

### One command from your local machine

```bash
cd ~/dotfiles
./deploy-to-server.sh <ssh-host>
```

Use any `Host` name from `ssh/config`. Examples:

```bash
./deploy-to-server.sh nuvoai-server-jhelum
./deploy-to-server.sh nuvoai-server-saryu
./deploy-to-server.sh kanpur-server-everest
```

The script will:
1. `rsync` the dotfiles to `~/dotfiles/` on the server
2. Install `zsh`, `git`, `curl` if missing (via apt)
3. Install Oh My Zsh, Powerlevel10k, and the three completion plugins
4. Symlink all dotfiles (`~/.zshrc`, `~/.p10k.zsh`, `~/.aliases`, etc.)
5. Set zsh as the default shell

Then open VS Code → **Remote SSH** → connect to the host → open a terminal.
You will get the same prompt, green command highlighting, and ghost suggestions.

### Adding a new server

1. Add its SSH config block to [`ssh/config`](ssh/config):

```
Host my-new-server
  HostName hostname.example.com
  Port 22
  User youruser
  IdentityFile ~/.ssh/id_ed25519
  IdentitiesOnly yes
```

2. Commit and push:

```bash
git add ssh/config && git commit -m "add my-new-server SSH host"
git push origin main
```

3. Deploy:

```bash
./deploy-to-server.sh my-new-server
```

---

## Daily Workflow

### Update system packages

```bash
supdate
```

This runs `~/dotfiles/installs/update_upgrade.sh` — uses `nala` if installed, otherwise `apt`.

### Capture current machine state into snapshots

Run this after installing new packages, VS Code extensions, or changing GNOME settings:

```bash
cd ~/dotfiles
./capture/capture-all.sh
```

Or capture just one slice:

```bash
./capture/capture-apt.sh            # apt packages
./capture/capture-vscode.sh         # VS Code extensions
./capture/capture-snap.sh           # snap packages
./capture/capture-flatpak.sh        # flatpak apps
./capture/capture-gnome-extensions.sh
./capture/capture-dconf.sh          # terminal profile, keybindings, etc.
```

Then commit and push:

```bash
git add snapshots/
git commit -m "refresh snapshot"
git push origin main
```

### Sync dotfile changes to a running server

After editing `.zshrc`, `.aliases`, `.p10k.zsh`, or `ssh/config` locally:

```bash
# Push changes to GitHub first
git push origin main

# Re-deploy to the server (rsync is incremental — only sends changed files)
./deploy-to-server.sh nuvoai-server-jhelum
```

### Edit and reload aliases without restarting terminal

```bash
# Edit
code ~/dotfiles/.aliases

# Reload in current session
source ~/.aliases
```

### Customize the prompt

```bash
p10k configure      # interactive wizard — regenerates ~/.p10k.zsh
```

After saving, the new config is live immediately. To commit it:

```bash
git add .p10k.zsh && git commit -m "update p10k config"
git push origin main
```

---

## Shell: zsh + Powerlevel10k

### What's active

| Feature | How it's loaded |
|---|---|
| Powerlevel10k prompt | `ZSH_THEME="powerlevel10k/powerlevel10k"` in `.zshrc` |
| Prompt layout / colors | `~/.p10k.zsh` (rainbow, nerdfont-v3, slanted separators) |
| Ghost suggestions | `zsh-autosuggestions` plugin |
| Syntax highlighting | `zsh-syntax-highlighting` plugin |
| Extended tab-completion | `zsh-completions` plugin |
| Git aliases (`gst`, `gco`, etc.) | `git` plugin (oh-my-zsh built-in) |

### Terminal shortcuts

| Key | Action |
|---|---|
| `→` or `End` | Accept full ghost suggestion |
| `Ctrl+F` | Accept next word of suggestion |
| `Tab` | Open navigable completion menu |
| `↑ ↓` in completion menu | Navigate options |
| `Enter` in completion menu | Select option |

### Syntax highlighting colours

| Colour | Meaning |
|---|---|
| **Green bold** | Valid command (`touch`, `mkdir`, `sudo`, `source`, functions, aliases) |
| **Red bold** | Unknown / misspelled command |
| Cyan bold | Reserved words (`if`, `for`, `while`) |
| Yellow | Quoted strings (`'text'`, `"text"`) |
| Magenta | Options (`-v`, `--verbose`) |
| Cyan underline | Paths that exist |
| Blue bold | Globs (`*.txt`), redirections (`>`), separators (`&&`) |

---

## VS Code Integrated Terminal

No extra setup needed. [`settings/VSCode-Settings.json`](settings/VSCode-Settings.json) already contains:

```json
"terminal.integrated.fontFamily": "MesloLGS NF",
"terminal.integrated.defaultProfile.linux": "zsh"
```

Open a **new** terminal panel in VS Code (`Ctrl+\``) and the full p10k prompt,
syntax highlighting, and autosuggestions will be active.

When connected via **Remote SSH**, VS Code:
- Uses the **remote server's** zsh (installed by `deploy-to-server.sh`)
- Renders fonts from your **local** MesloLGS NF installation
- Forwards your **local SSH agent** automatically (no agent needed on the server)

---

## Aliases Reference

### Custom Aliases (`.aliases`)

#### General

| Alias | Command | Description |
|---|---|---|
| `hg` | `history 0 \| grep` | Search shell history: `hg docker` |
| `ch` | `history 0 \| grep "git commit"` | List past commits from history |
| `supdate` | `~/dotfiles/installs/update_upgrade.sh` | apt update + upgrade + autoremove |
| `alert` | `notify-send …` | Desktop notification on command finish: `sleep 30; alert` |

#### File Listing

| Alias | Command | Description |
|---|---|---|
| `ls` | `ls --color` | Always colourised |
| `la` | `ls -lahF --color` | Long list, all files, human sizes |
| `ll` | `ls -alF --color` | Long list, all files |
| `l` | `ls -CF --color` | Compact columns |

#### Search

| Alias | Command | Description |
|---|---|---|
| `fd` | `find . -type d -iname` | Find directories: `fd "my*"` |
| `ff` | `find . -type f -iname` | Find files: `ff "*.py"` |
| `grep` | `grep --color=auto` | Always colourised grep |

#### Git (custom — not in oh-my-zsh)

| Alias | Command | Description |
|---|---|---|
| `gcaa` | `git add -A && git commit -v` | Stage everything + commit (diff in editor) |
| `gcamd` | `git add -A && git commit --amend` | Stage everything + amend last commit |

#### Python / Virtual Environments

| Alias | Command | Description |
|---|---|---|
| `tut_env` | `source ~/venvs/tutorial/bin/activate` | Activate tutorial venv |
| `wipe_env` | `rm -rf ~/venvs/tutorial && python3 -m venv ~/venvs/tutorial` | Recreate tutorial venv |

#### YouTube / Workspace (machine-specific)

| Alias | Command | Description |
|---|---|---|
| `yt` | `code ~/My_Drive/YouTube/Scripts/` | Open YouTube scripts in VS Code |
| `cyt` | `cd ~/My_Drive/YouTube/Scripts/` | cd to YouTube scripts |

---

### Git Plugin Aliases (oh-my-zsh `git` plugin — active automatically)

No setup needed. These are loaded by `plugins=(git)` in `.zshrc`.

#### Add

| Alias | Git command |
|---|---|
| `ga` | `git add` |
| `gaa` | `git add --all` |
| `gapa` | `git add --patch` — interactive hunk staging |
| `gau` | `git add --update` — tracked files only |

#### Branch

| Alias | Git command |
|---|---|
| `gb` | `git branch` |
| `gba` | `git branch --all` |
| `gbd` | `git branch --delete` |
| `gbD` | `git branch --delete --force` |
| `gbgd` | Delete all local branches whose remote tracking branch is gone |

#### Checkout / Switch

| Alias | Git command |
|---|---|
| `gco` | `git checkout` |
| `gcb` | `git checkout -b` — create and switch |
| `gcm` | `git checkout main` |
| `gsw` | `git switch` |
| `gswc` | `git switch --create` |

#### Commit

| Alias | Git command |
|---|---|
| `gc` | `git commit --verbose` |
| `gca` | `git commit --verbose --all` |
| `gc!` | `git commit --verbose --amend` |
| `gcn!` | `git commit --verbose --no-edit --amend` |
| `gcmsg` | `git commit --message` |
| `gcam` | `git commit --all --message` |

#### Diff

| Alias | Git command |
|---|---|
| `gd` | `git diff` |
| `gdca` | `git diff --cached` — staged changes |
| `gds` | `git diff --staged` |
| `gdw` | `git diff --word-diff` |

#### Fetch / Pull / Push

| Alias | Git command |
|---|---|
| `gf` | `git fetch` |
| `gfo` | `git fetch origin` |
| `gl` | `git pull` |
| `gpr` | `git pull --rebase` |
| `ggpull` | `git pull origin <current-branch>` |
| `gp` | `git push` |
| `gpf` | `git push --force-with-lease` — safe force push |
| `gpf!` | `git push --force` |
| `ggpush` | `git push origin <current-branch>` |

#### Log

| Alias | Git command |
|---|---|
| `glog` | `git log --oneline --decorate --graph` |
| `gloga` | `git log --oneline --decorate --graph --all` |
| `glol` | Coloured graph log with author + relative time |
| `glo` | `git log --oneline --decorate` |
| `glg` | `git log --stat` |

#### Merge / Rebase

| Alias | Git command |
|---|---|
| `gm` | `git merge` |
| `gmom` | `git merge origin/main` |
| `gma` | `git merge --abort` |
| `grb` | `git rebase` |
| `grbi` | `git rebase --interactive` |
| `grbc` | `git rebase --continue` |
| `grba` | `git rebase --abort` |

#### Reset / Restore

| Alias | Git command |
|---|---|
| `grh` | `git reset` |
| `grhh` | `git reset --hard` |
| `grhs` | `git reset --soft` |
| `grs` | `git restore` |
| `grss` | `git restore --source` |

#### Stash

| Alias | Git command |
|---|---|
| `gstl` | `git stash list` |
| `gstp` | `git stash pop` |
| `gsts` | `git stash show --patch` |
| `gstd` | `git stash drop` |
| `gstu` | `git stash push --include-untracked` |

#### Status

| Alias | Git command |
|---|---|
| `gst` | `git status` |
| `gss` | `git status --short` |
| `gsb` | `git status --short --branch` |

---

## File Reference

```
dotfiles/
├── install.sh                    # Main installer — symlinks, OS setup, snapshots
├── deploy-to-server.sh           # Push dotfiles + setup zsh on a remote server
│
├── .zshrc                        # zsh config: Oh My Zsh, p10k, plugins, history
├── .p10k.zsh                     # Powerlevel10k prompt layout and colours
├── .aliases                      # Custom shell aliases
├── .zprofile                     # Login shell env vars (PATH, etc.)
├── .bashrc / .bash_profile       # Bash equivalents (kept for compatibility)
├── .nanorc                       # Nano editor syntax highlighting
├── .private                      # Local-only secrets (not committed, gitignored)
│
├── ssh/
│   └── config                    # All SSH host definitions (included via ~/.ssh/config)
│
├── settings/
│   ├── VSCode-Settings.json      # VS Code user settings
│   ├── VSCode-Keybindings.json   # VS Code keybindings
│   ├── ruff.toml                 # Python linter config (symlinked to ~/.config/ruff/)
│   └── autostart/                # GNOME autostart .desktop files (Linux only)
│
├── installs/
│   ├── install-zsh-p10k.sh       # Oh My Zsh + p10k + plugins + MesloLGS NF fonts
│   │                             #   --no-fonts flag: skip fonts (for remote servers)
│   ├── update_upgrade.sh         # apt/nala update + upgrade + autoremove
│   ├── setup-third-party-repos.sh # Add apt repos for Chrome, VS Code, etc.
│   ├── restore-apt-packages.sh   # Restore apt packages from snapshots/
│   ├── restore-snap-packages.sh  # Restore snap packages
│   ├── restore-flatpak-apps.sh   # Restore flatpak apps
│   ├── restore-vscode-extensions.sh
│   ├── restore-gnome-extensions.sh
│   ├── restore-dconf.sh          # Restore terminal profile, keybindings, etc.
│   ├── install-vscode.sh         # Install VS Code via Microsoft apt repo
│   ├── install-git.sh            # Install latest git
│   ├── install-uv-astral.sh      # Install uv (fast Python package manager)
│   ├── install-chrome.sh
│   ├── install-nala.sh           # Install nala (prettier apt frontend)
│   └── toggle-idle-dim.sh        # Toggle screen dim on idle
│
├── capture/
│   ├── capture-all.sh            # Run all capture scripts at once
│   ├── capture-apt.sh            # Snapshot installed apt packages
│   ├── capture-vscode.sh         # Snapshot VS Code extensions
│   ├── capture-snap.sh           # Snapshot snap packages
│   ├── capture-flatpak.sh        # Snapshot flatpak apps
│   ├── capture-gnome-extensions.sh
│   └── capture-dconf.sh          # Snapshot dconf (terminal, keybindings, etc.)
│
└── snapshots/                    # Machine state snapshots (committed to git)
    ├── apt-packages.txt
    ├── snap-packages.txt
    ├── flatpak-apps.txt
    ├── vscode-extensions.txt
    ├── gnome-extensions-enabled.txt
    ├── THIRD-PARTY-REPOS.md      # Manual steps for repos with no script
    └── dconf/                    # Exported dconf branches
```

---

## Troubleshooting

**Prompt icons show as boxes or `?`**
The terminal font is not `MesloLGS NF`. Set it in:
- GNOME Terminal: Preferences → Profile → Text → Custom font → `MesloLGS NF`
- VS Code: already set via `VSCode-Settings.json` — open a new terminal panel

**p10k shows "instant prompt" warning about console output**
Something in `.zshrc` or `.aliases` is printing to stdout during startup.
Run `zsh -i -c exit 2>&1 | head -20` to see what's printing.

**`chsh` asks for a password on a remote server**
Run `chsh` manually after SSHing in, or ask your sysadmin to set your default shell.
Alternatively, add this to the server's `~/.bash_profile` to launch zsh automatically:
```bash
[ -x "$(command -v zsh)" ] && exec zsh
```

**SSH agent error on server: `Could not bind socket /ssh-agent.socket`**
Your `.zshrc` is already guarded — this only starts the agent when `XDG_RUNTIME_DIR`
is set (desktop sessions only). VS Code Remote SSH forwards your local agent automatically.

**`apt-get` restore fails halfway through**
Re-run the restore script — apt resumes from where it left off:
```bash
./installs/restore-apt-packages.sh
```

**`texlive-full` download fails (403 from mirror)**
Wait a minute and re-run. Or install a lighter variant:
```bash
sudo apt install texlive-latex-recommended
```

**`pulseaudio` breaks audio on Ubuntu 24.04**
Don't install it — Ubuntu 24.04 uses pipewire. It is already filtered from the apt snapshot.

**VS Code not found after install**
Run the fallback install:
```bash
./installs/install-vscode.sh
```

---

## Acknowledgments

- Originally forked from [Mathias Bynens' dotfiles](https://github.com/mathiasbynens/dotfiles)
- Prompt by [romkatv/powerlevel10k](https://github.com/romkatv/powerlevel10k)
- Shell framework by [ohmyzsh/ohmyzsh](https://github.com/ohmyzsh/ohmyzsh)
