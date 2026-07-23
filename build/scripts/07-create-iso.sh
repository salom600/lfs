#!/bin/bash
# SalamOS Step 07: Create ISO - Generate bootable live ISO image
# Fixed UEFI boot + ISOLINUX BIOS boot (hybrid ISO)
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

# === UNMOUNT virtual filesystems FIRST (before squashfs) ===
echo "[07-create-iso] Unmounting virtual filesystems..."
umount "$CHROOT_DIR/proc" 2>/dev/null || true
umount "$CHROOT_DIR/sys" 2>/dev/null || true
umount "$CHROOT_DIR/dev/pts" 2>/dev/null || true
umount "$CHROOT_DIR/dev" 2>/dev/null || true
umount "$CHROOT_DIR/run" 2>/dev/null || true

# Clean previous ISO build
rm -rf "$ISO_DIR" "$OUTPUT_DIR"
mkdir -p "$ISO_DIR" "$ISO_DIR/boot/grub" "$ISO_DIR/boot/isolinux" "$ISO_DIR/live" "$OUTPUT_DIR"

# === Create squashfs from chroot (lz4 compression for speed) ===
echo "[07-create-iso] Creating squashfs filesystem..."
mksquashfs "$CHROOT_DIR" "$ISO_DIR/live/$SQUASHFS_NAME" \
    -no-progress \
    -comp lz4 \
    -Xhc \
    -e boot/grub

# === Copy kernel and initrd from chroot ===
echo "[07-create-iso] Copying kernel and initrd..."
cp "$CHROOT_DIR/boot/vmlinuz-*" "$ISO_DIR/live/vmlinuz"
cp "$CHROOT_DIR/boot/initrd.img-*" "$ISO_DIR/live/initrd"

# === ISOLINUX setup (BIOS boot) ===
echo "[07-create-iso] Setting up ISOLINUX for BIOS boot..."
ISOLINUX_DIR="/usr/lib/ISOLINUX"
GRUB_PC_DIR="/usr/lib/grub/i386-pc"

# Copy ISOLINUX files
cp "$ISOLINUX_DIR/isolinux.bin" "$ISO_DIR/boot/isolinux/"
cp "$ISOLINUX_DIR/ldlinux.c32" "$ISO_DIR/boot/isolinux/"

# Copy all required ISOLINUX modules
for module in libcom32.c32 libutil.c32 vesamenu.c32 chain.c32 reboot.c32 poweroff.c32; do
    if [ -f "$ISOLINUX_DIR/$module" ]; then
        cp "$ISOLINUX_DIR/$module" "$ISO_DIR/boot/isolinux/"
    fi
done

# Create ISOLINUX config
cat > "$ISO_DIR/boot/isolinux/isolinux.cfg" << IEOF
UI vesamenu.c32
MENU TITLE SalamOS 2026.1 (Zen)
MENU BACKGROUND /boot/isolinux/salamos-isolinux-bg.png
MENU COLOR title 1;36;44 #ffffff #0d1123 0
MENU COLOR hotsel 30;47 #ffffff #1f4068 0
MENU COLOR sel 30;47 #ffffff #1f4068 0
MENU COLOR border 30;44 #ffffff #0d1123 0
MENU COLOR tabmsg 31;40 #ffffff #16213e 0
MENU COLOR timeout 37;40 #ffffff #16213e 0
MENU COLOR timeout_msg 37;40 #ffffff #16213e 0
MENU COLOR hotkey 1;36;44 #7c3aed #0d1123 0

TIMEOUT 50
DEFAULT live

LABEL live
    MENU LABEL ^Start SalamOS (Live)
    KERNEL /live/vmlinuz
    APPEND initrd=/live/initrd boot=live quiet splash hostname=SalamOS username=salamos

LABEL safe
    MENU LABEL ^Safe Mode (nomodeset)
    KERNEL /live/vmlinuz
    APPEND initrd=/live/initrd boot=live quiet splash hostname=SalamOS username=salamos nomodeset

LABEL debug
    MENU LABEL ^Debug Mode
    KERNEL /live/vmlinuz
    APPEND initrd=/live/initrd boot=live hostname=SalamOS username=salamos

LABEL reboot
    MENU LABEL ^Reboot
    COM32 reboot.c32

LABEL poweroff
    MENU LABEL ^Shutdown
    COM32 poweroff.c32
IEOF

# Copy ISOLINUX background if available
if [[ -f "$PROJECT_ROOT/build/resources/salamos-grub.png" ]]; then
    cp "$PROJECT_ROOT/build/resources/salamos-grub.png" "$ISO_DIR/boot/isolinux/salamos-isolinux-bg.png"
fi

# === GRUB EFI setup (UEFI boot) ===
echo "[07-create-iso] Setting up GRUB EFI for UEFI boot..."

# Create EFI boot directory structure
mkdir -p "$ISO_DIR/EFI/BOOT"

# Generate GRUB EFI image (standalone)
# This creates a self-contained EFI boot image that includes all necessary modules
if command -v grub-mkimage &>/dev/null; then
    echo "[07-create-iso] Generating GRUB standalone EFI image..."
    
    # Create a temporary grub directory for standalone image
    GRUB_EFI_TMP=$(mktemp -d)
    mkdir -p "$GRUB_EFI_TMP/boot/grub"
    
    # Create GRUB config for EFI boot
    cat > "$GRUB_EFI_TMP/boot/grub/grub.cfg" << GEOF
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
insmod normal
insmod configfile

# Load SalamOS wallpaper if available
if background_image /boot/grub/salamos-grub.png ; then
  set color_normal=white/black
  set color_highlight=yellow/black
else
  set color_normal=light-gray/black
  set color_highlight=yellow/black
fi

menuentry "SalamOS 2026.1 (Live)" {
    linux /live/vmlinuz boot=live quiet splash hostname=SalamOS username=salamos
    initrd /live/initrd
}

menuentry "SalamOS 2026.1 (Live - Safe Mode)" {
    linux /live/vmlinuz boot=live quiet splash hostname=SalamOS username=salamos nomodeset
    initrd /live/initrd
}

menuentry "SalamOS 2026.1 (Debug Mode)" {
    linux /live/vmlinuz boot=live hostname=SalamOS username=salamos
    initrd /live/initrd
}

menuentry "System Restart" {
    reboot
}

menuentry "System Shutdown" {
    halt
}
GEOF
    
    # Build standalone EFI image with embedded config
    # The -c flag embeds the config file directly into the EFI image
    grub-mkimage -O x86_64-efi \
        -o "$ISO_DIR/EFI/BOOT/BOOTX64.EFI" \
        -p "/boot/grub" \
        -c "$GRUB_EFI_TMP/boot/grub/grub.cfg" \
        all_video boot btrfs cat chain configfile echo efifwsetup efi_gop \
        efi_uga fat font gfxmenu gfxterm gzio hfsplus iso9660 linux \
        loadenv loopback ls lsefi normal part_apple part_msdos part_gpt \
        png read reboot search search_fs_uuid search_fs_file search_label \
        squash4 test true video video_fb xfs
    
    rm -rf "$GRUB_EFI_TMP"
    echo "[07-create-iso] GRUB EFI image created successfully"
fi

# Also create the ISO's /boot/grub/grub.cfg for when GRUB loads from disk
cat > "$ISO_DIR/boot/grub/grub.cfg" << GEOF2
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
insmod normal
insmod configfile

if background_image /boot/grub/salamos-grub.png ; then
  set color_normal=white/black
  set color_highlight=yellow/black
else
  set color_normal=light-gray/black
  set color_highlight=yellow/black
fi

menuentry "SalamOS 2026.1 (Live)" {
    linux /live/vmlinuz boot=live quiet splash hostname=SalamOS username=salamos
    initrd /live/initrd
}

menuentry "SalamOS 2026.1 (Live - Safe Mode)" {
    linux /live/vmlinuz boot=live quiet splash hostname=SalamOS username=salamos nomodeset
    initrd /live/initrd
}

menuentry "SalamOS 2026.1 (Debug Mode)" {
    linux /live/vmlinuz boot=live hostname=SalamOS username=salamos
    initrd /live/initrd
}

menuentry "System Restart" {
    reboot
}

menuentry "System Shutdown" {
    halt
}
GEOF2

# Copy GRUB resources if available
if [[ -f "$PROJECT_ROOT/build/resources/salamos-grub.png" ]]; then
    cp "$PROJECT_ROOT/build/resources/salamos-grub.png" "$ISO_DIR/boot/grub/"
fi

# === Create hybrid ISO with xorriso ===
echo "[07-create-iso] Generating hybrid ISO image..."

# ISOLINUX MBR for BIOS boot
ISOLINUX_MBR="/usr/lib/ISOLINUX/isohdpfx.bin"

xorriso -as mkisofs \
    -iso-level 3 \
    -full-iso9660-filenames \
    -V "$ISO_VOLUME_ID" \
    -publisher "$ISO_publisher" \
    -A "$ISO_APPLICATION" \
    --modification-date=$(date +%Y%m%d%H%M%S00) \
    -isohybrid-mbr "$ISOLINUX_MBR" \
    -eltorito-boot boot/isolinux/isolinux.bin \
    -no-emul-boot \
    -boot-load-size 4 \
    -boot-info-table \
    --eltorito-catalog boot/isolinux/boot.cat \
    -eltorito-alt-boot \
    -e EFI/BOOT/BOOTX64.EFI \
    -no-emul-boot \
    -isohybrid-gpt-basdat \
    --protective-msdos-label \
    -output "$OUTPUT_DIR/$ISO_NAME" \
    "$ISO_DIR"

echo "[07-create-iso] ISO created successfully!"
echo "[07-create-iso] ISO size: $(du -sh "$OUTPUT_DIR/$ISO_NAME" | cut -f1)"
