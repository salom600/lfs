#!/bin/bash
# SalamOS Step 01: Debootstrap - Create minimal Debian base system
# ============================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BUILD_ROOT="$(dirname "$SCRIPT_DIR")"
source "$BUILD_ROOT/config/vars"

CHROOT_DIR="$BUILD_ROOT/$CHROOT_DIR"

echo "[01-debootstrap] Creating minimal Debian $BASE_SUITE base system..."

# Clean previous build
if [[ -d "$CHROOT_DIR" ]]; then
    echo "[01-debootstrap] Removing previous chroot..."
    rm -rf "$CHROOT_DIR"
fi

mkdir -p "$CHROOT_DIR"

# Run debootstrap with minimal variant
echo "[01-debootstrap] Running debootstrap --variant=minbase..."
debootstrap \
    --variant=minbase \
    --arch="$BASE_ARCH" \
    --include=systemd,dbus,apt,bash,coreutils,dpkg,passwd,adduser,sudo \
    "$BASE_SUITE" \
    "$CHROOT_DIR" \
    "$BASE_MIRROR"

echo "[01-debootstrap] Base system created successfully"
echo "[01-debootstrap] Size: $(du -sh "$CHROOT_DIR" | cut -f1)"
