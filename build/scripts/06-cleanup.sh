#!/bin/bash
# SalamOS Step 06: Cleanup - Remove unnecessary files and optimize
# ============================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BUILD_ROOT="$(dirname "$SCRIPT_DIR")"
source "$BUILD_ROOT/config/vars"

CHROOT_DIR="$BUILD_ROOT/$CHROOT_DIR"

echo "[06-cleanup] Cleaning up and optimizing..."

chroot "$CHROOT_DIR" /bin/bash << CHEOF

# Remove documentation
rm -rf /usr/share/doc/*
rm -rf /usr/share/info/*
rm -rf /usr/share/man/*
rm -rf /usr/share/locale/*/  # Keep only en and ar
cp -a /usr/share/locale/en /tmp/locale_en
cp -a /usr/share/locale/ar /tmp/locale_ar
rm -rf /usr/share/locale/*
mv /tmp/locale_en /usr/share/locale/en
mv /tmp/locale_ar /usr/share/locale/ar

# Remove unnecessary logs
rm -rf /var/log/*
mkdir -p /var/log
touch /var/log/syslog

# Remove temp files
rm -rf /tmp/*
rm -rf /var/tmp/*

# Remove apt cache
apt-get clean
rm -rf /var/cache/apt/archives/*
rm -rf /var/cache/apt/*.bin

# Remove dpkg cache
rm -rf /var/lib/apt/lists/*
mkdir -p /var/lib/apt/lists/partial

# Remove unnecessary systemd unit files
rm -f /lib/systemd/system/apt-daily.service
rm -f /lib/systemd/system/apt-daily-upgrade.service

# Disable swap file creation
rm -f /etc/init.d/swapfile*

# Zero out free space (for better squashfs compression)
echo "[06-cleanup] Zeroing free space for compression..."
dd if=/dev/zero of=/zero.fill bs=1M || true
rm -f /zero.fill

# Clear bash history
cat /dev/null > ~/.bash_history
cat /dev/null > /home/$DEFAULT_USER/.bash_history

# Set machine-id (required for systemd)
echo "[06-cleanup] Setting machine-id..."
dbus-uuidgen > /etc/machine-id
cp /etc/machine-id /var/lib/dbus/machine-id

# Create empty machine-id for live system (will be generated on first boot)
# This ensures each live boot gets a unique machine-id
echo "" > /etc/machine-id

CHEOF

echo "[06-cleanup] Cleanup completed"
echo "[06-cleanup] Final chroot size: $(du -sh "$CHROOT_DIR" | cut -f1)"
