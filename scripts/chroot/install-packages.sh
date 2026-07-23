#!/bin/bash
# SalamOS Package Installation - Install all packages inside chroot
# ============================================
set -e
export PATH=/usr/sbin:/usr/bin:/sbin:/bin
export DEBIAN_FRONTEND=noninteractive

apt-get update

# === CORE SYSTEM (must succeed) ===
apt-get install -y --no-install-recommends \
  linux-image-amd64 \
  initramfs-tools \
  live-boot \
  grub2 grub-pc grub-pc-bin \
  systemd dbus \
  network-manager network-manager-gnome \
  wpasupplicant \
  sudo polkitd ufw \
  curl wget ca-certificates \
  openssh-client \
  xserver-xorg-core xserver-xorg-video-all xserver-xorg-input-all \
  xorg xinit \
  lightdm lightdm-gtk-greeter \
  openbox obconf \
  pcmanfm lxterminal mousepad \
  firefox-esr \
  alsa-utils pulseaudio pulseaudio-utils \
  acpi acpid upower \
  htop nano vim-tiny \
  gvfs gvfs-backends udisks2 \
  xdg-utils desktop-file-utils \
  fonts-dejavu fonts-hack \
  adwaita-icon-theme \
  firmware-linux-free \
  ntfs-3g dosfstools \
  usbutils pciutils

# === USER-FRIENDLY DESKTOP (must succeed) ===
apt-get install -y --no-install-recommends \
  tint2 jgmenu \
  feh nitrogen picom \
  conky rofi \
  gtk2-engines \
  papirus-icon-theme \
  fonts-liberation fonts-noto \
  file-roller p7zip-full unzip \
  gparted \
  lshw tlp \
  evince scrot lxappearance \
  dunst \
  volumeicon-alsa \
  lxshortcut \
  synaptic \
  gdebi \
  packagekit \
  calamares \
  calamares-settings-debian \
  xdg-user-dirs

# === OPTIONAL (allow failure) ===
apt-get install -y --no-install-recommends firmware-misc-nonfree 2>/dev/null || echo "SKIP: firmware-misc-nonfree"
apt-get install -y --no-install-recommends live-boot-initramfs-tools 2>/dev/null || echo "SKIP: live-boot-initramfs-tools"
apt-get install -y --no-install-recommends gtk3-engines-breeze 2>/dev/null || echo "SKIP: gtk3-engines-breeze"
apt-get install -y --no-install-recommends pavucontrol 2>/dev/null || echo "SKIP: pavucontrol"
apt-get install -y --no-install-recommends firefox-esr-l10n-ar 2>/dev/null || echo "SKIP: firefox-esr-l10n-ar"
apt-get install -y --no-install-recommends fonts-noto-cjk 2>/dev/null || echo "SKIP: fonts-noto-cjk"
apt-get install -y --no-install-recommends light-locker 2>/dev/null || echo "SKIP: light-locker"
apt-get install -y --no-install-recommends xfce4-power-manager 2>/dev/null || echo "SKIP: xfce4-power-manager"

apt-get autoremove -y --purge 2>/dev/null || true
apt-get clean
rm -rf /var/cache/apt/archives/* /var/lib/apt/lists/*

echo "=== Running update-initramfs ==="
which update-initramfs 2>/dev/null || ls /usr/sbin/update-initramfs 2>/dev/null || echo "WARNING: update-initramfs not found"
/usr/sbin/update-initramfs -u -k all || echo "WARNING: update-initramfs failed"

echo "Packages installed successfully"
