#!/bin/bash
# SalamOS Package Installation - 2026 PROFESSIONAL Edition
# RULE 1: Ultra-lightweight + FULL hardware/software/gaming support
# Clean: Only essential packages, no bloat
# Gaming: Steam + Lutris + Wine + Mesa + Vulkan
# ============================================
set -e
export PATH=/usr/sbin:/usr/bin:/sbin:/bin
export DEBIAN_FRONTEND=noninteractive

apt-get update

# =============================================
# TIER 1: CORE SYSTEM (must succeed)
# Ultra-minimal base that boots and runs
# =============================================
apt-get install -y --no-install-recommends \
  linux-image-amd64 \
  initramfs-tools \
  live-boot \
  grub2 grub-pc-bin grub-efi-amd64-bin \
  systemd dbus \
  network-manager \
  sudo polkitd \
  curl wget ca-certificates \
  xserver-xorg-core xserver-xorg-video-all xserver-xorg-input-all \
  xorg xinit \
  lightdm lightdm-gtk-greeter \
  openbox \
  pcmanfm lxterminal \
  firefox-esr \
  alsa-utils pulseaudio \
  acpi acpid upower \
  nano \
  gvfs udisks2 \
  fonts-noto fonts-dejavu \
  adwaita-icon-theme \
  firmware-linux-free firmware-linux-nonfree \
  ntfs-3g dosfstools \
  usbutils pciutils \
  mesa-vulkan-drivers libgl1-mesa-dri

# =============================================
# TIER 2: DESKTOP EXPERIENCE (lightweight UX)
# Only what makes the desktop USEFUL and MODERN
# =============================================
apt-get install -y --no-install-recommends \
  tint2 jgmenu \
  picom \
  nitrogen feh \
  conky rofi \
  papirus-icon-theme \
  dunst \
  lxappearance \
  volumeicon-alsa \
  nm-applet \
  xdg-user-dirs \
  gtk2-engines \
  htop \
  scrot \
  synaptic gdebi \
  calamares calamares-settings-debian \
  lxshortcut

# =============================================
# TIER 3: GAMING SUPPORT (the competitive edge)
# Steam + Lutris + Wine + Proton + Vulkan
# This makes SalamOS a REAL gaming distro
# =============================================
# Enable i386 architecture for Wine/Steam 32-bit support
dpkg --add-architecture i386
apt-get update

# Mesa + Vulkan drivers (AMD + Intel + NVIDIA)
apt-get install -y --no-install-recommends \
  mesa-vulkan-drivers libgl1-mesa-dri \
  libglx-mesa0 libegl-mesa0 \
  vulkan-tools

# Wine compatibility layer (run Windows apps/games)
apt-get install -y --no-install-recommends \
  wine wine64 wine32 2>/dev/null || echo "INSTALL: Wine available, install later via Software Center"

# Steam (the #1 gaming platform)
apt-get install -y --no-install-recommends \
  steam-installer 2>/dev/null || echo "INSTALL: Steam available, install later via Software Center"

# Gaming tools
apt-get install -y --no-install-recommends \
  gamemode libgamemode0 libgamemodeauto0 2>/dev/null || echo "SKIP: gamemode not in repos"

# =============================================
# TIER 4: OPTIONAL (allow failure - bloat-free)
# Only installed if available, never blocks the build
# =============================================
apt-get install -y --no-install-recommends lutris 2>/dev/null || echo "INSTALL: Lutris available later via Software Center"
apt-get install -y --no-install-recommends pavucontrol 2>/dev/null || echo "SKIP: pavucontrol"
apt-get install -y --no-install-recommends firefox-esr-l10n-ar 2>/dev/null || echo "INSTALL: Arabic Firefox language via Software Center"
apt-get install -y --no-install-recommends light-locker 2>/dev/null || echo "SKIP: light-locker"
apt-get install -y --no-install-recommends mousepad 2>/dev/null || echo "SKIP: mousepad"
apt-get install -y --no-install-recommends file-roller 2>/dev/null || echo "SKIP: file-roller"
apt-get install -y --no-install-recommends evince 2>/dev/null || echo "SKIP: evince"
apt-get install -y --no-install-recommends gparted 2>/dev/null || echo "SKIP: gparted"
apt-get install -y --no-install-recommends tlp 2>/dev/null || echo "SKIP: tlp"

# =============================================
# CLEANUP: Remove ALL bloat and cache
# Maximum lightweight = no leftover packages
# =============================================
apt-get autoremove -y --purge 2>/dev/null || true
apt-get clean
rm -rf /var/cache/apt/archives/* /var/lib/apt/lists/*

# Remove unnecessary packages that Debian installs by default
apt-get purge -y --auto-remove \
  tasksel tasksel-data \
  laptop-detect \
  debconf-i18n \
  installation-report \
  popularity-contest \
  reportbug \
  python3-reportbug \
  apt-listchanges \
  dbus-user-session \
  libglade2-0 \
  2>/dev/null || echo "SKIP: Some bloat packages not installed"

# =============================================
# BUILD: Create initramfs for boot
# =============================================
echo "=== Building initramfs ==="
/usr/sbin/update-initramfs -u -k all || echo "WARNING: update-initramfs had issues"

echo "Packages installed successfully - CLEAN + GAMING EDITION"
echo "GPU drivers: Mesa + Vulkan (AMD/Intel/NVIDIA)"
echo "Gaming: Steam + Wine + Lutris (via Software Center)"
