#!/bin/bash
# SalamOS Customization - Apply branding and system customization inside chroot
# ============================================
set -e
export PATH=/usr/sbin:/usr/bin:/sbin:/bin

# === OS Identity ===
cat > /etc/os-release << 'OEOF'
NAME="SalamOS"
VERSION="2026.1 (Zen)"
ID=salamos
ID_LIKE=debian
PRETTY_NAME="SalamOS 2026.1"
VERSION_ID="2026.1"
HOME_URL="https://github.com/salom600/lfs"
SUPPORT_URL="https://github.com/salom600/lfs"
BUG_REPORT_URL="https://github.com/salom600/lfs/issues"
VERSION_CODENAME=zen
DEBIAN_CODENAME=bookworm
OEOF

echo 'SalamOS 2026.1' > /etc/issue
echo 'SalamOS 2026.1' > /etc/issue.net

cat > /etc/motd << 'MEOF'
Welcome to SalamOS 2026.1 (Zen)
Ultra-lightweight professional Linux distribution

Quick commands:
  update  - Update system
  install - Install packages
  clean   - Clean system
MEOF

# === User bash config ===
cat > /home/salamos/.bashrc << 'BEOF'
export PS1='\u@\h:\w\$ '
export EDITOR=nano
export BROWSER=firefox-esr
alias ll='ls -la'
alias update='sudo apt-get update && sudo apt-get upgrade'
alias install='sudo apt-get install'
alias remove='sudo apt-get remove --purge'
alias search='apt-cache search'
alias clean='sudo apt-get autoremove --purge && sudo apt-get clean'
BEOF
chown salamos:salamos /home/salamos/.bashrc

# === GRUB config ===
cat > /etc/default/grub << 'GEOF'
GRUB_DEFAULT=0
GRUB_TIMEOUT=5
GRUB_DISTRIBUTOR="SalamOS"
GRUB_CMDLINE_LINUX_DEFAULT="quiet splash"
GRUB_CMDLINE_LINUX=""
GEOF

# === Systemd services ===
systemctl mask apt-daily.service || true
systemctl mask apt-daily-upgrade.service || true
systemctl mask apt-daily.timer || true
systemctl mask apt-daily-upgrade.timer || true
systemctl mask NetworkManager-wait-online.service || true

systemctl enable NetworkManager.service || true
systemctl enable lightdm.service || true
systemctl enable acpid.service || true
systemctl enable upower.service || true
systemctl set-default graphical.target || true

echo "Customization done"
