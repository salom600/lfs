#!/bin/bash
# SalamOS Chroot Setup - Configure base system inside chroot
# ============================================
set -e
export PATH=/usr/sbin:/usr/bin:/sbin:/bin
export DEBIAN_FRONTEND=noninteractive

apt-get update

# Set root password
echo "root:root" | chpasswd

# Create default user (with autologin group for LightDM)
groupadd -r autologin 2>/dev/null || true
useradd -m -s /bin/bash -G sudo,adm,disk,autologin salamos
echo "salamos:salamos" | chpasswd

# Configure locale (English + Arabic)
sed -i 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen
sed -i 's/# ar_SA.UTF-8 UTF-8/ar_SA.UTF-8 UTF-8/' /etc/locale.gen
locale-gen
echo 'LANG=en_US.UTF-8' > /etc/default/locale

# Configure timezone
echo 'Africa/Lagos' > /etc/timezone
ln -sf /usr/share/zoneinfo/Africa/Lagos /etc/localtime

# Configure keyboard (Arabic + English toggle)
cat > /etc/default/keyboard << 'KEOF'
XKBMODEL="pc105"
XKBLAYOUT="us,ara"
XKBOPTIONS="grp:alt_shift_toggle"
KEOF

# Configure sudo for default user
echo 'salamos ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers.d/salamos
chmod 440 /etc/sudoers.d/salamos

echo "Chroot setup done"
