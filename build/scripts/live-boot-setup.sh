#!/bin/bash
# SalamOS Live Boot Setup Script
# Configures the system for live boot (run inside chroot)
# ============================================

set -euo pipefail

echo "[live-boot] Setting up live boot system..."

# Install live-boot package
apt-get install -y --no-install-recommends live-boot live-boot-initramfs-tools

# Configure live-boot
cat > /etc/live/boot.conf << EOF
# SalamOS Live Boot Configuration

LIVE_MEDIA=cdrom
LIVE_MEDIA_MOUNT_DIR=/live/media
LIVE_UNION_PROC=true
LIVE_UNION_TYPE=overlayfs
LIVE_USERNAME=salamos
LIVE_USER_FULLNAME=SalamOS User
LIVE_HOSTNAME=SalamOS
LIVE_SWAP=false
LIVE_READ_ONLY=false
EOF

# Update initramfs to include live-boot
update-initramfs -u -k all

echo "[live-boot] Live boot configured"
