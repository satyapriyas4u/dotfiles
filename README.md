# Development Environment Setup

This repository contains scripts and configuration files to set up a development environment for macOS. It's tailored for software development, focusing on a clean, minimal, and efficient setup.

## YouTube Video Walkthrough

Click on the image below to watch the video on YouTube:

[![Watch the video](https://img.youtube.com/vi/ra5kMCXO-6I/0.jpg)](https://youtu.be/ra5kMCXO-6I)

## Overview

The setup includes automated scripts for installing essential software, configuring Bash and Zsh shells, and setting up Sublime Text and Visual Studio Code editors. This guide will help you replicate my development environment on your machine if you desire to do so.

## Important Note Before Installation

**WARNING:** The configurations and scripts in this repository are **HIGHLY PERSONALIZED** to my own preferences and workflows. If you decide to use them, please be aware that they will **MODIFY** your current system, potentially making some changes that are **IRREVERSIBLE** without a fresh installation of your operating system.

Furthermore, while I strive to backup files wherever possible, I cannot guarantee that all files are backed up. The backup mechanism is designed to backup SOME files **ONCE**. If the script is run more than once, the initial backups will be **OVERWRITTEN**, potentially resulting in loss of data. While I could implement timestamped backups to preserve multiple versions, this setup is optimized for my personal use, and a single backup suffices for me.

If you would like a development environment similar to mine, I highly encourage you to fork this repository and make your own personalized changes to these scripts instead of running them exactly as I have them written for myself.

A less serious (but potentially annoying) change it will make is setting the Desktop background to the image I use in my tutorials. This is the script I use to set up machines I will be recording on, after all.

I likely won't accept pull requests unless they align closely with my personal preferences and the way I use my development environment. But if there are some obvious errors in my scripts then corrections would be welcome!

If you choose to run these scripts, please do so with **EXTREME CAUTION**. It's recommended to review the scripts and understand the changes they will make to your system before proceeding.

By using these scripts, you acknowledge and accept the risk of potential data loss or system alteration. Proceed at your own risk.

## Getting Started

### Prerequisites

-  macOS (The scripts are tailored for macOS)

### Installation

1. Clone the repository to your local machine:
   ```sh
   git clone https://github.com/CoreyMSchafer/dotfiles.git ~/dotfiles
   ```
2. Navigate to the `dotfiles` directory:
   ```sh
   cd ~/dotfiles
   ```
3. Run the installation script:
   ```sh
   ./install.sh
   ```

This script will:

-  Create symlinks for dotfiles (`.bashrc`, `.zshrc`, etc.)
-  Run macOS-specific configurations
-  Install Homebrew packages and casks
-  Configure Sublime Text and Visual Studio Code

## Replicating a Full Ubuntu Setup (capture / restore)

For Ubuntu users who want to mirror an existing machine onto a new one, this
repo includes a snapshot layer that records:

-  apt-installed packages (`snapshots/apt-packages.txt`)
-  snap packages (`snapshots/snap-packages.txt`)
-  flatpak applications (`snapshots/flatpak-apps.txt`)
-  VS Code extensions (`snapshots/vscode-extensions.txt`)
-  GNOME Shell extensions + their settings (`snapshots/gnome-extensions-enabled.txt`, `snapshots/dconf/gnome-shell-extensions.dconf`)
-  Targeted dconf branches: gnome-terminal profile, desktop interface,
   input sources, mutter, keybindings (`snapshots/dconf/*.dconf`)

### Refreshing the snapshot (on the current laptop)

```sh
./capture/capture-all.sh
git add snapshots/ && git commit -m "refresh snapshot"
git push
```

Each capture script is self-contained — run individually if you only want
to refresh one slice (e.g. `./capture/capture-vscode.sh`).

### Restoring onto a new laptop

1.  Clone this repo and run the usual `./install.sh`. The Linux path
    detects the `snapshots/` directory and offers to restore from it.
2.  Before the apt restore, run the interactive helper:
    ```bash
    ./installs/setup-third-party-repos.sh
    ```
    to enable the apt repos for Chrome, VS Code, AnyDesk, Grafana,
    VirtualBox, Warp, etc. See
    [snapshots/THIRD-PARTY-REPOS.md](snapshots/THIRD-PARTY-REPOS.md)
    for the full list (some apps like Zoom, MongoDB Compass, FortiClient,
    EdrawMax have no apt repo and need a manual `.deb` download).
3.  GNOME extensions are reinstalled fresh from extensions.gnome.org via
    `gnome-extensions-cli`. You'll need to log out and back in once for
    the shell to load them.

### Known gotchas on Ubuntu 24.04

-  **`texlive-full` is 4+ GB.** During my own migration the in.archive
   mirror started returning `403 Forbidden` part-way through the download,
   which cascaded to other packages in the same apt transaction. If you
   see that, just re-run `./installs/restore-apt-packages.sh` after a
   minute — apt picks up where it left off. If you don't need full
   TeX Live, install `texlive-latex-recommended` instead.
-  **Don't install `pulseaudio` on 24.04.** It conflicts with
   `pipewire-audio` (the default), and pulling it in silently breaks audio.
   It's filtered out of the apt snapshot for that reason.
-  **Mainline kernel headers** (`linux-headers-6.8.12-060812-*`) aren't in
   the standard archive. If you need a specific mainline kernel, grab it
   from [kernel.ubuntu.com/mainline](https://kernel.ubuntu.com/mainline/)
   directly. These are also filtered out of the snapshot.
-  **VS Code without the Microsoft repo:** [vscode.sh](vscode.sh) offers
   `snap install code --classic` as a fallback if `code` isn't found.

To skip the snapshot restore on a given run (e.g. when bootstrapping a
machine you don't want fully populated), export `SKIP_RESTORE=1` before
running `./install.sh`.

## Aliases & Shell Commands

### Custom Aliases (`.aliases`)

#### General Shortcuts

| Alias | Expands to | Description |
|---|---|---|
| `hg` | `history 0 \| grep` | Search command history |
| `ch` | `history 0 \| grep "git commit"` | Show all past commits |
| `supdate` | `~/dotfiles/installs/update_upgrade.sh` | Run system apt update + upgrade |
| `alert` | `notify-send …` | Desktop notification when a long command finishes: `sleep 30; alert` |

#### File Listing

| Alias | Expands to | Description |
|---|---|---|
| `ls` | `ls --color` | Always colorized |
| `la` | `ls -lahF --color` | Long list, all files, human-readable sizes |
| `ll` | `ls -alF --color` | Long list, all files |
| `l` | `ls -CF --color` | Compact columns |

#### Search

| Alias | Expands to | Description |
|---|---|---|
| `fd` | `find . -type d -iname` | Find directories by name |
| `ff` | `find . -type f -iname` | Find files by name |
| `grep` | `grep --color=auto` | Always colorized grep |

#### Git (custom, not in oh-my-zsh plugin)

| Alias | Expands to | Description |
|---|---|---|
| `gcaa` | `git add -A && git commit -v` | Stage everything and commit (verbose diff in editor) |
| `gcamd` | `git add -A && git commit --amend` | Stage everything and amend last commit |

#### Python / Virtual Environments

| Alias | Expands to | Description |
|---|---|---|
| `tut_env` | `source ~/venvs/tutorial/bin/activate` | Activate the tutorial venv |
| `wipe_env` | `rm -rf ~/venvs/tutorial && python3 -m venv ~/venvs/tutorial` | Recreate tutorial venv from scratch |

#### YouTube / Workspace (machine-specific)

| Alias | Expands to | Description |
|---|---|---|
| `yt` | `code ~/My_Drive/YouTube/Scripts/` | Open YouTube scripts in VS Code |
| `cyt` | `cd ~/My_Drive/YouTube/Scripts/` | cd to YouTube scripts |

---

### Git Plugin Aliases (oh-my-zsh `git` plugin — active automatically)

These are provided by `plugins=(git)` in `.zshrc`. No setup needed — just type them.

#### Add

| Alias | Git command |
|---|---|
| `ga` | `git add` |
| `gaa` | `git add --all` |
| `gapa` | `git add --patch` (interactive hunk staging) |
| `gau` | `git add --update` (tracked files only) |

#### Branch

| Alias | Git command |
|---|---|
| `gb` | `git branch` |
| `gba` | `git branch --all` |
| `gbd` | `git branch --delete` |
| `gbD` | `git branch --delete --force` |
| `gbgd` | Delete all local branches whose remote is gone |

#### Checkout / Switch

| Alias | Git command |
|---|---|
| `gco` | `git checkout` |
| `gcb` | `git checkout -b` (create + switch) |
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
| `gdca` | `git diff --cached` (staged changes) |
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
| `gpf` | `git push --force-with-lease` (safe force push) |
| `gpf!` | `git push --force` |
| `ggpush` | `git push origin <current-branch>` |

#### Log

| Alias | Git command |
|---|---|
| `glog` | `git log --oneline --decorate --graph` |
| `gloga` | `git log --oneline --decorate --graph --all` |
| `glol` | Colored graph log with author + relative time |
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

## Configuration Files

-  `.bashrc` & `.zshrc`: Shell configuration files for Bash and Zsh.
-  `.shared_prompt`: Custom prompt setup used by both `.bash_prompt` & `.zprompt`
-  `.bash_prompt` & `.zprompt`: Custom prompt setup for Bash and Zsh.
-  `.bash_profile: Setting system-wide environment variables
-  `.aliases`: Aliases for common commands. Some are personalized to my machines specifically (e.g. the 'yt' alias opening my YouTube Scripts')
-  `.private`: This is a file you'll create locally to hold private information and shouldn't be uploaded to version control
-  `settings/`: Directory containing editor settings and themes for Sublime Text and Visual Studio Code.

### Customizing Your Setup

You're encouraged to modify the scripts and configuration files to suit your preferences. Here are some tips for customization:

-  **Dotfiles**: Edit `.shared_prompt`, `.zprompt`, `.bash_prompt` to add or modify shell configurations.
-  **Sublime Text and VS Code**: Adjust settings in the `settings/` directory to change editor preferences and themes.
-  **Workspace 2 on login**: The Linux installer currently includes `settings/autostart/switch-to-workspace-2.desktop`, which runs `wmctrl -s 1` after login on X11 and switches GNOME to workspace 2.
-  **Right-click terminal and new text file support**: The installer now adds `nautilus-extension-gnome-terminal` and creates `~/Templates/New Text File.txt` on Linux. That enables Nautilus context menu actions like "Open in Terminal" and "New Document → New Text File".
-  **Capture current settings**: After making desktop or GNOME changes, run `./capture/capture-all.sh` to refresh `snapshots/`. Then commit the updated snapshot files with `git add snapshots/ && git commit -m "refresh snapshot"`.

## Contributing

Feel free to fork this repository and customize it for your setup. Pull requests for improvements and bug fixes are welcome, but as said above, I likely won't accept pull requests that simply add additional brew installations or change some settings unless they align with my personal preferences.

## License

This project is licensed under the MIT License - see the [LICENSE-MIT.txt](LICENSE-MIT.txt) file for details.

## Acknowledgments

-  I originally forked this from [Mathias Bynens' dotfiles](https://github.com/mathiasbynens/dotfiles)
-  Thanks to all the open-source projects used in this setup.
