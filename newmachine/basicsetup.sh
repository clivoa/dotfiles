#!/bin/bash
# System bootstrap script (Debian/Kali-based)
# - Updates the system
# - Installs common tools
# - Installs Oh My Zsh and sets Zsh as default shell
# - Installs tmux plugin manager (TPM)
# - Installs clipboard helpers (xsel/xclip)
# - Installs and configures SPICE agent (clipboard + resize + integration on VMs)
# - Enables SSH
# - Installs Sublime Text (official repository)

set -euo pipefail

echo "[+] Updating system"
sudo apt update
sudo apt full-upgrade -y

echo "[+] Installing favorite tools"
sudo apt install -y \
  kali-linux-top10 \
  gobuster \
  feroxbuster \
  seclists \
  neovim \
  tmux \
  zsh \
  flameshot \
  curl \
  git

echo "[+] Installing clipboard helpers (xsel/xclip)"
# Some tools/plugins prefer one or the other; installing both avoids surprises.
sudo apt-get install -y xsel xclip

echo "[+] Installing Oh My Zsh (unattended)"
if [ ! -d "$HOME/.oh-my-zsh" ]; then
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi

echo "[+] Setting Zsh as default shell"
if command -v zsh >/dev/null 2>&1; then
  chsh -s "$(command -v zsh)"
fi

echo "[+] Installing tmux plugin manager (TPM)"
TPM_DIR="$HOME/.tmux/plugins/tpm"
if [ ! -d "$TPM_DIR" ]; then
  git clone https://github.com/tmux-plugins/tpm "$TPM_DIR"
fi

echo "[+] Installing and configuring SPICE agent (for VM integration)"
sudo apt update
sudo apt install -y spice-vdagent

# Enable the SPICE daemon (service name may vary by distro, so we try both)
sudo systemctl enable --now spice-vdagentd 2>/dev/null || true
sudo systemctl enable --now spice-vdagent 2>/dev/null || true

# Autostart spice-vdagent in desktop sessions (GNOME/Xfce/etc.)
echo "[+] Creating autostart entry for spice-vdagent"
mkdir -p "$HOME/.config/autostart"
cat > "$HOME/.config/autostart/spice-vdagent.desktop" <<'EOF'
[Desktop Entry]
Type=Application
Exec=spice-vdagent
Hidden=false
NoDisplay=false
X-GNOME-Autostart-enabled=true
Name=SPICE Agent
EOF

# Start spice-vdagent for the current session if possible (won't fail script if not applicable)
spice-vdagent >/dev/null 2>&1 & disown || true

echo "[+] Enabling SSH server"
sudo systemctl enable --now ssh

echo "[+] Installing Sublime Text (official repository)"
sudo install -d -m 0755 /etc/apt/keyrings
wget -qO - https://download.sublimetext.com/sublimehq-pub.gpg | sudo tee /etc/apt/keyrings/sublimehq-pub.asc > /dev/null
echo -e 'Types: deb\nURIs: https://download.sublimetext.com/\nSuites: apt/stable/\nComponents: \nSigned-By: /etc/apt/keyrings/sublimehq-pub.asc' \
  | sudo tee /etc/apt/sources.list.d/sublime-text.sources > /dev/null

sudo apt update
sudo apt-get install -y sublime-text

echo "[+] Setup completed 🎉"
echo "[i] Notes:"
echo "    - TPM installed at: $TPM_DIR"
echo "    - SPICE autostart file: ~/.config/autostart/spice-vdagent.desktop"
echo "    - Zsh default shell takes effect on next login."
