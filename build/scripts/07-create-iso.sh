#!/bin/bash
# SalamOS Step 07: Create ISO - Generate bootable live ISO image
# ============================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BUILD_ROOT="$(dirname "$SCRIPT_DIR")"
PROJECT_ROOT="$(dirname "$BUILD_ROOT")"
source "$BUILD_ROOT/config/vars"

CHROOT_DIR="$BUILD_ROOT/$CHROOT_DIR"
ISO_DIR="$BUILD_ROOT/$ISO_DIR"
OUTPUT_DIR="$BUILD_ROOT/output"

echo "[07-create-iso] Creating bootable live ISO..."

# Clean previous ISO build
rm -rf "$ISO_DIR" "$OUTPUT_DIR"
mkdir -p "$ISO_DIR" "$ISO_DIR/boot/grub" "$ISO_DIR/live" "$OUTPUT_DIR"

# Create squashfs from chroot
echo "[07-create-iso] Creating squashfs filesystem..."
mksquashfs "$CHROOT_DIR" "$ISO_DIR/live/$SQUASHFS_NAME" \
    -no-progress \
    -comp zstd \
    -Xcompression-level 19 \
    -e boot/grub

# Copy kernel and initrd from chroot
echo "[07-create-iso] Copying kernel and initrd..."
cp "$CHROOT_DIR/boot/vmlinuz-*" "$ISO_DIR/live/vmlinuz"
cp "$CHROOT_DIR/boot/initrd.img-*" "$ISO_DIR/live/initrd"

# Create GRUB configuration for live boot
cat > "$ISO_DIR/boot/grub/grub.cfg" << GEOF
set gfxpayload=keep
set default=0
set timeout=5

insmod all_video
insmod gfxterm
insmod png
insmod part_gpt
insmod part_msdos
insmod ext2
insmod search
insmod search_fs_uuid

# Load SalamOS wallpaper if available
if background_image /boot/grub/salamos-grub.png ; then
  set color_normal=white/black
  set color_highlight=yellow/black
else
  set color_normal=light-gray/black
  set color_highlight=yellow/black
fi

menuentry "$DISTRO_NAME $DISTRO_VERSION (Live)" {
    linux /live/vmlinuz boot=live quiet splash hostname=$DISTRO_NAME username=$DEFAULT_USER
    initrd /live/initrd
}

menuentry "$DISTRO_NAME $DISTRO_VERSION (Live - Safe Mode)" {
    linux /live/vmlinuz boot=live quiet splash hostname=$DISTRO_NAME username=$DEFAULT_USER nomodeset
    initrd /live/initrd
}

menuentry "$DISTRO_NAME $DISTRO_VERSION (Live - Debug Mode)" {
    linux /live/vmlinuz boot=live hostname=$DISTRO_NAME username=$DEFAULT_USER
    initrd /live/initrd
}

menuentry "$DISTRO_NAME $DISTRO_VERSION (Install to Disk)" {
    linux /live/vmlinuz boot=live quiet splash hostname=$DISTRO_NAME username=$DEFAULT_USER install
    initrd /live/initrd
}

menuentry "System Restart" {
    reboot
}

menuentry "System Shutdown" {
    halt
}
GEOF

# Copy GRUB resources if available
if [[ -f "$PROJECT_ROOT/build/resources/salamos-grub.png" ]]; then
    cp "$PROJECT_ROOT/build/resources/salamos-grub.png" "$ISO_DIR/boot/grub/"
fi

# Create EFI boot structure for UEFI support
mkdir -p "$ISO_DIR/EFI/BOOT"
# We'll use GRUB EFI for UEFI boot
if command -v grub-mkimage &>/dev/null; then
    grub-mkimage -O x86_64-efi \
        -o "$ISO_DIR/EFI/BOOT/BOOTX64.EFI" \
        -p "/boot/grub" \
        all_video boot btrfs cat chain configfile echo efifwsetup efi_gop \
        efi_uga fat font gfxmenu gfxterm gzio hfsplus iso9660 linux \
        loadenv loopback ls lsefi normal part_apple part_msdos part_gpt \
        png read reboot search search_fs_uuid search_fs_file search_label \
        squash4 test true video video_fb xfs
fi

# Create the ISO using xorriso
echo "[07-create-iso] Generating ISO image with xorriso..."
xorriso -as mkisofs \
    -iso-level 3 \
    -full-iso9660-filenames \
    -V "$ISO_VOLUME_ID" \
    -publisher "$ISO_publisher" \
    -A "$ISO_APPLICATION" \
    --modification-date=$(date +%Y%m%d%H%M%S00) \
    -isohybrid-mbr /usr/lib/ISOLINUX/isohdpfx.bin \
    -eltorito-boot boot/grub/i386-pc/eltorito.img \
    -no-emul-boot \
    -boot-load-size 4 \
    -boot-info-table \
    --eltorito-catalog boot/grub/boot.cat \
    --grub2-boot-info \
    --efi-boot EFI/BOOT/BOOTX64.EFI \
    -no-emul-boot \
    --efi-boot-image \
    --protective-msdos-label \
    -output "$OUTPUT_DIR/$ISO_NAME" \
    "$ISO_DIR"

echo "[07-create-iso] ISO created successfully!"
echo "[07-create-iso] ISO size: $(du -sh "$OUTPUT_DIR/$ISO_NAME" | cut -f1)"

# Unmount chroot filesystems
echo "[07-create-iso] Unmounting chroot filesystems..."
umount "$CHROOT_DIR/proc" 2>/dev/null || true
umount "$CHROOT_DIR/sys" 2>/dev/null || true
umount "$CHROOT_DIR/dev/pts" 2>/dev/null || true
umount "$CHROOT_DIR/dev" 2>/dev/null || true
umount "$CHROOT_DIR/run" 2>/dev/null || true
