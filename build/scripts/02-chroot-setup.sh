#!/bin/bash
# SalamOS Step 02: Chroot Setup - Configure base system in chroot
# ============================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BUILD_ROOT="$(dirname "$SCRIPT_DIR")"
source "$BUILD_ROOT/config/vars"

CHROOT_DIR="$BUILD_ROOT/$CHROOT_DIR"

echo "[02-chroot-setup] Setting up chroot environment..."

# Mount necessary filesystems for chroot
mount --bind /dev "$CHROOT_DIR/dev"
mount --bind /dev/pts "$CHROOT_DIR/dev/pts"
mount --bind /proc "$CHROOT_DIR/proc"
mount --bind /sys "$CHROOT_DIR/sys"
mount --bind /run "$CHROOT_DIR/run"

# Ensure resolv.conf works
cp /etc/resolv.conf "$CHROOT_DIR/etc/resolv.conf"

# Configure apt sources
cat > "$CHROOT_DIR/etc/apt/sources.list" << EOF
deb $BASE_MIRROR $BASE_SUITE main contrib non-free-firmware
deb $BASE_MIRROR $BASE_SUITE-updates main contrib non-free-firmware
deb http://deb.debian.org/debian-security $BASE_SUITE-security main contrib non-free-firmware
EOF

# Set hostname
echo "$DISTRO_NAME" > "$CHROOT_DIR/etc/hostname"

# Set hosts
cat > "$CHROOT_DIR/etc/hosts" << EOF
127.0.0.1       localhost
127.0.1.1       $DISTRO_NAME

# The following lines are desirable for IPv6 capable hosts
::1     localhost ip6-localhost ip6-loopback
ff02::1 ip6-allnodes
ff02::2 ip6-allrouters
EOF

# Create default user
chroot "$CHROOT_DIR" /bin/bash << CHEOF
# Update apt
apt-get update

# Set root password
echo "root:$ROOT_PASSWORD" | chpasswd

# Create default user
useradd -m -s /bin/bash -G sudo,adm,disk "$DEFAULT_USER"
echo "$DEFAULT_USER:$DEFAULT_PASSWORD" | chpasswd

# Configure locale
sed -i 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen
sed -i 's/# ar_SA.UTF-8 UTF-8/ar_SA.UTF-8 UTF-8/' /etc/locale.gen
locale-gen
echo 'LANG=en_US.UTF-8' > /etc/default/locale

# Configure timezone
echo 'Africa/Lagos' > /etc/timezone
ln -sf /usr/share/zoneinfo/Africa/Lagos /etc/localtime

# Configure keyboard
cat > /etc/default/keyboard << KEOF
XKBMODEL="pc105"
XKBLAYOUT="us,ara"
XKBVARIANT=","
XKBOPTIONS="grp:alt_shift_toggle,lv3:ralt_switch"
KEYBOARD_CONFIG="/etc/default/keyboard"
KEOF

# Set bash as default shell
chsh -s /bin/bash root
chsh -s /bin/bash "$DEFAULT_USER"

# Configure sudo for default user
echo "$DEFAULT_USER ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/$DEFAULT_USER
chmod 440 /etc/sudoers.d/$DEFAULT_USER

CHEOF

echo "[02-chroot-setup] Chroot environment configured successfully"
