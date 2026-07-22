#!/bin/bash
# SalamOS Step 03: Packages - Install essential packages & remove bloat
# ============================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BUILD_ROOT="$(dirname "$SCRIPT_DIR")"
source "$BUILD_ROOT/config/vars"

CHROOT_DIR="$BUILD_ROOT/$CHROOT_DIR"
PACKAGES_LIST="$BUILD_ROOT/config/packages.list"
PACKAGES_REMOVE="$BUILD_ROOT/config/packages-remove.list"

echo "[03-packages] Installing and configuring packages..."

# Read package list (filter comments and empty lines)
PACKAGES=$(grep -vE '^\s*#|^\s*$' "$PACKAGES_LIST" | tr '\n' ' ')

# Read removal list
REMOVE_PACKAGES=$(grep -vE '^\s*#|^\s*$' "$PACKAGES_REMOVE" | tr '\n' ' ')

chroot "$CHROOT_DIR" /bin/bash << CHEOF

# Update package database
apt-get update

# Configure apt to avoid installing recommended/suggested packages
cat > /etc/apt/apt.conf.d/99-no-recommends << AEOF
APT::Install-Recommends "false";
APT::Install-Suggests "false";
APT::AutoRemove::RecommendsImportant "false";
APT::AutoRemove::SuggestsImportant "false";
AEOF

# Install essential packages
echo "[03-packages] Installing: $PACKAGES"
apt-get install -y --no-install-recommends $PACKAGES

# Remove unwanted packages
echo "[03-packages] Removing bloat..."
for pkg in $REMOVE_PACKAGES; do
    if dpkg -l "\$pkg" &>/dev/null; then
        apt-get purge -y "\$pkg" || true
    fi
done

# Reinstall only needed Firefox language packs
apt-get install -y --no-install-recommends firefox-esr-l10n-ar firefox-esr-l10n-en-us || true

# Autoremove orphaned packages
apt-get autoremove -y --purge

# Clean apt cache
apt-get clean
rm -rf /var/cache/apt/archives/*
rm -rf /var/lib/apt/lists/*

# Update initramfs
update-initramfs -u -k all

CHEOF

echo "[03-packages] Packages installed successfully"
echo "[03-packages] Chroot size: $(du -sh "$CHROOT_DIR" | cut -f1)"
