#!/bin/bash
# SalamOS Step 04: Customize - Apply SalamOS branding and customizations
# ============================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BUILD_ROOT="$(dirname "$SCRIPT_DIR")"
PROJECT_ROOT="$(dirname "$BUILD_ROOT")"
source "$BUILD_ROOT/config/vars"

CHROOT_DIR="$BUILD_ROOT/$CHROOT_DIR"
OVERLAY_DIR="$PROJECT_ROOT/overlays"

echo "[04-customize] Applying SalamOS customizations..."

# Copy overlay files into chroot
if [[ -d "$OVERLAY_DIR" ]]; then
    echo "[04-customize] Copying overlay files..."
    cp -a "$OVERLAY_DIR/etc" "$CHROOT_DIR/etc/" 2>/dev/null || true
    cp -a "$OVERLAY_DIR/usr" "$CHROOT_DIR/usr/" 2>/dev/null || true
    cp -a "$OVERLAY_DIR/home" "$CHROOT_DIR/home/" 2>/dev/null || true
fi

# Apply customizations in chroot
chroot "$CHROOT_DIR" /bin/bash << CHEOF

# Set distribution identity
cat > /etc/os-release << OEOF
NAME="$DISTRO_NAME"
VERSION="$DISTRO_VERSION (Zen)"
ID=salamos
ID_LIKE=debian
PRETTY_NAME="$DISTRO_NAME $DISTRO_VERSION"
VERSION_ID="$DISTRO_VERSION"
HOME_URL="$DISTRO_URL"
SUPPORT_URL="$DISTRO_URL"
BUG_REPORT_URL="$DISTRO_URL/issues"
VERSION_CODENAME=zen
DEBIAN_CODENAME=bookworm
OEOF

# Update issue files
echo "$DISTRO_NAME $DISTRO_VERSION \\n \\l" > /etc/issue
echo "$DISTRO_NAME $DISTRO_VERSION" > /etc/issue.net

# Configure login message
cat > /etc/motd << MEOF
Welcome to $DISTRO_NAME $DISTRO_VERSION (Zen)
Ultra-lightweight professional Linux distribution

System resources: 
  - Idle RAM usage: ~150MB
  - ISO size: < 500MB
  - Desktop: Openbox WM + tint2 panel

Type 'help' for available commands.
MEOF

# Configure bash prompt for user
cat > /home/$DEFAULT_USER/.bashrc << BEOF
# SalamOS Custom Bash Configuration
export PS1='\\u@\\h:\\w\\$ '
export EDITOR=nano
export BROWSER=firefox-esr

# Aliases
alias ll='ls -la'
alias la='ls -A'
alias l='ls -CF'
alias update='sudo apt-get update && sudo apt-get upgrade'
alias install='sudo apt-get install'
alias remove='sudo apt-get remove --purge'
alias search='apt-cache search'
alias info='apt-cache show'
alias clean='sudo apt-get autoremove --purge && sudo apt-get clean'

# SalamOS help
help() {
    echo "SalamOS Quick Commands:"
    echo "  update    - Update system"
    echo "  install   - Install package"
    echo "  remove    - Remove package"
    echo "  search    - Search packages"
    echo "  info      - Package info"
    echo "  clean     - Clean system"
}
BEOF

chown $DEFAULT_USER:$DEFAULT_USER /home/$DEFAULT_USER/.bashrc

# Configure GRUB distribution name
sed -i "s/GRUB_DISTRIBUTOR=.*$/GRUB_DISTRIBUTOR=\"$DISTRO_NAME\"/" /etc/default/grub

# Configure GRUB timeout and defaults
cat > /etc/default/grub << GEOF
GRUB_DEFAULT=0
GRUB_TIMEOUT=5
GRUB_DISTRIBUTOR="$DISTRO_NAME"
GRUB_CMDLINE_LINUX_DEFAULT="quiet splash"
GRUB_CMDLINE_LINUX=""
GRUB_BACKGROUND=/usr/share/backgrounds/salamos/salamos-wallpaper.png
GEOF

# Configure systemd to minimize services
systemctl mask apt-daily.service
systemctl mask apt-daily-upgrade.service
systemctl mask apt-daily.timer
systemctl mask apt-daily-upgrade.timer
systemctl mask NetworkManager-wait-online.service

# Set default runlevel to graphical
systemctl set-default graphical.target

# Enable essential services
systemctl enable NetworkManager.service
systemctl enable lightdm.service
systemctl enable acpid.service
systemctl enable upower.service
systemctl enable ufw.service
systemctl enable tlp.service

CHEOF

echo "[04-customize] Customizations applied successfully"
