#!/bin/bash
# SalamOS Cleanup - Remove unnecessary files to minimize ISO size
# ============================================
set -e
export PATH=/usr/sbin:/usr/bin:/sbin:/bin

# Remove documentation (not needed for lightweight distro)
rm -rf /usr/share/doc/* /usr/share/info/* /usr/share/man/*

# Keep only English and Arabic locales
cp -a /usr/share/locale/en /tmp/locale_en 2>/dev/null || true
cp -a /usr/share/locale/ar /tmp/locale_ar 2>/dev/null || true
rm -rf /usr/share/locale/*
mv /tmp/locale_en /usr/share/locale/en 2>/dev/null || true
mv /tmp/locale_ar /usr/share/locale/ar 2>/dev/null || true

# Clean logs
rm -rf /var/log/*
mkdir -p /var/log
touch /var/log/syslog
rm -rf /tmp/* /var/tmp/*

# Clean apt cache
apt-get clean 2>/dev/null || true
rm -rf /var/cache/apt/archives/* /var/cache/apt/*.bin /var/lib/apt/lists/*
mkdir -p /var/lib/apt/lists/partial

# Generate machine-id (needed for dbus) but clear it for live boot
dbus-uuidgen > /etc/machine-id 2>/dev/null || true
cp /etc/machine-id /var/lib/dbus/machine-id 2>/dev/null || true
printf '' > /etc/machine-id

# Zero-fill free space (makes squashfs smaller)
dd if=/dev/zero of=/zero.fill bs=1M 2>/dev/null || true
rm -f /zero.fill

# Clear bash history
cat /dev/null > ~/.bash_history 2>/dev/null || true
cat /dev/null > /home/salamos/.bash_history 2>/dev/null || true

echo "Cleanup done"
