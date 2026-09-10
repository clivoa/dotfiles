# Multiplatform Basic Setup Design

## Goal

Transform `newmachine/basicsetup.sh` into an idempotent bootstrap for current macOS, Ubuntu, Kali, Arch Linux, and Omarchy machines. The script installs every tool required by the repository's active configuration, installs every application already present in the original setup, and links repository configuration only when the destination does not already exist.

## Scope

The setup covers:

- core command-line and build tools;
- Zsh, Oh My Zsh, Spaceship, shell integrations, and Ruby through rbenv;
- tmux, TPM, and configured tmux plugins;
- Vim and its plugins;
- Neovim, LazyVim, and current LazyVim runtime requirements;
- Git and conditional GPG signing configuration;
- Ghostty, Sublime Text, Flameshot, and OrbStack where supported;
- Gobuster, Feroxbuster, SecLists, OpenVPN, and Kali's top-ten metapackage where applicable;
- clipboard helpers, OpenSSH, and SPICE integration where applicable;
- Claude Code, which is required by the `claude-deepseek` shell function;
- Hack Nerd Font, which is referenced by the Ghostty configuration.

The setup does not overwrite, merge, rename, or back up an existing user configuration. It does not perform a full operating-system upgrade. It does not import private keys, authenticate cloud tools, or enable macOS remote access.

## Architecture

The implementation remains a single Bash entry point organized into small functions with one responsibility each. The script resolves the repository root relative to its own path, so it can be invoked from any working directory.

The main phases are:

1. Detect the operating system, distribution, CPU architecture, desktop capabilities, and available package manager.
2. Install bootstrap prerequisites required by subsequent phases.
3. Install missing common tools through a platform adapter.
4. Install tools that need version checks or vendor-specific sources.
5. Install shell, editor, and tmux plugin ecosystems.
6. Configure applicable services.
7. Create safe symbolic links for absent configurations.
8. Validate commands, versions, links, and required services.
9. Print a categorized summary and return a meaningful exit status.

Shared `ensure_*` helpers detect existing commands, packages, directories, repositories, services, and links. Platform adapters encapsulate Homebrew, APT, and Pacman behavior instead of scattering platform conditionals throughout the script.

## Platform Detection

- `uname -s` equal to `Darwin` selects macOS.
- Linux reads `/etc/os-release`.
- `ID=ubuntu` and `ID=kali` select the Debian-family adapter.
- `ID=arch` selects the Arch adapter.
- An Arch system is classified as Omarchy when `$HOME/.local/share/omarchy` exists or an `omarchy-*` management command is available.
- Other operating systems and distributions stop before mutation with a clear unsupported-platform message.
- `uname -m` is normalized to `x86_64` or `arm64` for vendor binary downloads.

Omarchy uses the Arch package adapter for individual missing packages, but the script never calls `pacman -Syu` or `yay -Syu`. This avoids bypassing Omarchy's own system migration and update flow.

## Installation Policy

Every component is checked before installation. Package operations are batched per native package manager when possible.

### Common command-line tools

The common set is Git, curl, wget, CA certificates, GPG, Zsh, tmux, Vim, fzf, zoxide, ripgrep, fd, lazygit, jq, unzip, tar, Make, a C compiler, ShellCheck, OpenVPN, and Universal Ctags. Linux also receives `xclip` and `xsel`.

macOS uses Homebrew formulae after ensuring Homebrew is available. Ubuntu and Kali use APT for packages that meet requirements. Arch and Omarchy use official Pacman repositories, with an existing AUR helper used only for software unavailable in official repositories.

### Neovim and LazyVim

Neovim must be at least version `0.11.2`, matching the current LazyVim requirement. Homebrew and Pacman packages are accepted only after the installed version passes this check. On Ubuntu or Kali, an adequate APT package is accepted; otherwise the stable official Neovim archive for the detected architecture is installed under `/opt` with an executable exposed on the system `PATH`.

The setup also ensures LazyVim's active runtime dependencies: Git, curl, a C compiler, fzf, ripgrep, fd, lazygit, and `tree-sitter-cli`. The disabled example plugin file is not treated as an active package specification.

After linking a previously absent `~/.config/nvim`, the script performs a headless LazyVim synchronization. On later runs it validates the installation without replacing user state. The final report recommends `:LazyHealth` for interactive diagnostics.

### Zsh and Ruby

The setup installs Oh My Zsh unattended only when absent. Spaceship, zsh-autosuggestions, and zsh-syntax-highlighting are installed through native packages or their upstream repositories and discovered dynamically by the Zsh configuration.

Ruby management is standardized on rbenv. The script installs rbenv and ruby-build, installs Ruby `3.4.1` only when that version is absent, and sets it as the default rbenv version. chruby initialization is removed to avoid two Ruby managers rewriting `PATH` in the same shell.

Zsh becomes the default shell only when it is installed, listed as an allowed shell when the platform requires that, and different from the user's current login shell.

### tmux and Vim plugins

TPM is cloned only when absent. The setup then runs TPM's noninteractive plugin installer so `tmux-sensible`, Dracula, and the Linux weather plugin are present according to the selected configuration.

Vim-Plug and configured Vim plugins are installed noninteractively when `~/.vimrc` has just been linked or the plugin manager is missing. Make, ctags, Git, curl, fzf, and ripgrep are installed first because the Vim configuration relies on them.

### Applications and security tools

- macOS installs Ghostty, Sublime Text, Flameshot, OrbStack, and Hack Nerd Font through Homebrew casks.
- Ubuntu and Kali install Sublime Text through its signed vendor repository, Flameshot through APT, Hack Nerd Font in the user's font directory, and Ghostty through an installation path documented by the Ghostty project for Ubuntu-compatible systems.
- Arch and Omarchy install Ghostty, Flameshot, and Hack Nerd Font from official repositories. Sublime Text uses an already available AUR helper or its official archive fallback.
- Gobuster, Feroxbuster, SecLists, and OpenVPN are installed on every platform using a native package when available and an upstream release or repository fallback otherwise.
- `kali-linux-top10` is installed only when `/etc/os-release` identifies Kali.

SecLists has one stable location exposed to the user even when it is installed by cloning the upstream repository rather than by a distribution package.

### Claude Code

Claude Code is installed only when `claude` is absent. macOS uses the stable Homebrew cask. Ubuntu and Kali use Anthropic's signed stable APT repository and validate the published signing-key fingerprint `31DD DE24 DDFA B679 F42D 7BD2 BAA9 29FF 1A7E CACE` before trusting it. Arch and Omarchy use Anthropic's native stable installer in user scope.

Authentication remains manual and is listed in the final summary. The DeepSeek API key remains outside version control in `~/.zsh_secrets`.

## Service Policy

OpenSSH server and SPICE are Linux-only operations.

- Ubuntu and Kali install `openssh-server`; Arch and Omarchy install `openssh`.
- SSH is enabled only when systemd is available.
- SPICE is installed and enabled only when the package exists for the detected platform and systemd is available.
- The desktop autostart entry for `spice-vdagent` is created only in a graphical Linux environment and only when absent.
- macOS does not enable Remote Login or create SPICE configuration.

## Dotfile Compatibility Changes

The current hard-coded Homebrew paths must be removed so linked configuration works outside Apple Silicon macOS.

- `zsh/.zshrc` discovers Homebrew with `brew --prefix` when available, searches standard Linux package paths otherwise, and guards every optional integration before sourcing or initializing it.
- The OpenVPN path is derived from the installed command instead of a pinned Cellar version.
- Vim resolves through `PATH`; no alias points to a versioned Homebrew Cellar directory.
- chruby initialization is removed and rbenv remains the only Ruby manager.
- `zsh/.zprofile` initializes rbenv only when the command exists and keeps OrbStack optional.
- `ghostty/config` starts tmux through `PATH` instead of `/opt/homebrew/bin/tmux`.

The macOS-only Ghostty titlebar option remains in the shared configuration because it is a valid Ghostty key and has no Linux effect.

## Safe Link Policy

The selected links are:

- `zsh/.zshrc` to `~/.zshrc`;
- `zsh/.zprofile` to `~/.zprofile`;
- `tmux/.tmux_mac.conf` to `~/.tmux.conf` on macOS;
- `tmux/.tmux_linux.conf` to `~/.tmux.conf` on Linux;
- `vimrc/.vimrc` to `~/.vimrc`;
- `nvim` to `~/.config/nvim`;
- `ghostty/config` to `~/.config/ghostty/config`;
- `git/.gitconfig` to `~/.gitconfig` only when the configured private signing key exists.

For each target:

- a correct existing link is recorded as already configured;
- an absent target receives a parent directory and symbolic link;
- a regular file, directory, or link to another source is preserved and recorded as skipped;
- no automatic backup, merge, replacement, or deletion occurs.

Before linking Git configuration, `gpg --list-secret-keys BFCBBE5225945724` must succeed. Otherwise GPG is installed, the link is skipped, and the final summary asks the user to import the private key and rerun the setup.

## Failure Handling and Reporting

The script tracks installed, already-present, skipped, manual-action, and failed items. It continues after a noncritical application or desktop integration failure so independent components can still be configured.

Failures in bootstrap prerequisites, Git, curl, Zsh, tmux, a compatible Neovim, or required configuration links make the final exit status nonzero. Platform-inapplicable services and desktop integrations are skipped with a reason and do not count as failures.

External downloads use a temporary directory. Checksums, package signatures, and signing-key fingerprints are verified whenever the publisher provides them. Temporary files are removed on normal exit and signals.

The final output includes installed components, components already present, preserved configurations, unsupported or inapplicable items, failures, and actions that remain manual. Manual actions include restarting the login session after `chsh`, authenticating Claude Code, defining `DEEPSEEK_API_KEY`, importing the Git signing key, and running interactive editor health checks.

## Test Strategy

The script exposes a `main` function and does not execute it when sourced by tests. Tests use a temporary home directory and command shims rather than invoking real package managers or changing the host.

Automated coverage includes:

- macOS, Ubuntu, Kali, Arch, and Omarchy detection;
- unsupported-platform rejection before mutation;
- `x86_64` and `arm64` normalization;
- Neovim semantic version comparison around `0.11.2`;
- package selection for each supported platform;
- missing-only installation behavior;
- safe creation and idempotence of file and directory links;
- preservation of existing targets and foreign symlinks;
- platform-specific tmux configuration selection;
- conditional Git configuration based on the private GPG key;
- absence of full-upgrade operations, especially on Omarchy;
- accumulated failure reporting and exit status;
- Bash syntax with `bash -n` and static analysis with ShellCheck.

## Acceptance Criteria

1. Running the script twice performs no duplicate installations or destructive configuration changes.
2. The script supports macOS, Ubuntu, Kali, Arch, and Omarchy on `x86_64` and `arm64` where upstream software is available.
3. Every active dependency referenced by repository configuration is installed or explicitly reported as unavailable or requiring manual action.
4. Every original setup component remains covered on platforms where it applies.
5. LazyVim starts with a compatible Neovim and its required external commands.
6. Existing user configuration is never overwritten.
7. Git signing configuration is not activated without the matching private key.
8. macOS-specific paths no longer break Zsh or Ghostty on Linux.
9. Automated tests pass without installing software or mutating the real home directory.
