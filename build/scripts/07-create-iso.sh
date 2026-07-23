#!/bin/bash
# SalamOS Step 07: Create ISO - Generate bootable live ISO image
# ISOLINUX BIOS boot + EFI System Partition UEFI boot (hybrid ISO)
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
mkdir -p "$ISO_DIR" "$ISO_DIR/isolinux" "$ISO_DIR/boot/grub" "$ISO_DIR/live" "$OUTPUT_DIR"

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
SYSLINUX_BIOS="/usr/lib/syslinux/modules/bios"

cp "$ISOLINUX_DIR/isolinux.bin" "$ISO_DIR/isolinux/"
cp "$ISOLINUX_DIR/ldlinux.c32" "$ISO_DIR/isolinux/"

for module in libcom32.c32 libutil.c32 vesamenu.c32 chain.c32 reboot.c32 poweroff.c32; do
    if [ -f "$SYSLINUX_BIOS/$module" ]; then
        cp "$SYSLINUX_BIOS/$module" "$ISO_DIR/isolinux/"
    elif [ -f "$ISOLINUX_DIR/$module" ]; then
        cp "$ISOLINUX_DIR/$module" "$ISO_DIR/isolinux/"
    fi
done

cat > "$ISO_DIR/isolinux/isolinux.cfg" << IEOF
DEFAULT vesamenu.c32
TIMEOUT 50
PROMPT 0
MENU TITLE SalamOS 2026.1 (Zen)
MENU BACKGROUND background.png
MENU COLOR title 0 #dce6ff #0d1123
MENU COLOR sel 7 #ffffff #7c3aed
MENU COLOR unsel 0 #dce6ff #0d1123
MENU COLOR border 0 #7c3aed #0d1123
MENU COLOR hotsel 7 #ffffff #7c3aed
MENU COLOR hotkey 1 #7c3aed #0d1123

LABEL live
  MENU LABEL ^Start SalamOS 2026.1 (Live)
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

LABEL halt
  MENU LABEL ^Shutdown
  COM32 poweroff.c32
IEOF

if [[ -f "$PROJECT_ROOT/build/resources/salamos-grub.png" ]]; then
    cp "$PROJECT_ROOT/build/resources/salamos-grub.png" "$ISO_DIR/isolinux/background.png"
fi

# === GRUB config for UEFI boot (on ISO filesystem) ===
cat > "$ISO_DIR/boot/grub/grub.cfg" << GEOF
search --set=root --file /boot/grub/grub.cfg
set prefix=($root)/boot/grub

set gfxpayload=keep
set default=0
set timeout=5

insmod all_video
insmod gfxterm
insmod png
insmod part_gpt
insmod part_msdos
insmod iso9660
insmod squash4
insmod normal
insmod configfile

if [ -f ($root)/boot/grub/salamos-grub.png ]; then
    background_image ($root)/boot/grub/salamos-grub.png
    set color_normal=white/black
    set color_highlight=yellow/black
else
    set color_normal=light-gray/black
    set color_highlight=yellow/black
fi

menuentry "SalamOS 2026.1 (Live)" {
    linux ($root)/live/vmlinuz boot=live quiet splash hostname=SalamOS username=salamos
    initrd ($root)/live/initrd
}

menuentry "SalamOS 2026.1 (Safe Mode)" {
    linux ($root)/live/vmlinuz boot=live quiet splash hostname=SalamOS username=salamos nomodeset
    initrd ($root)/live/initrd
}

menuentry "SalamOS 2026.1 (Debug Mode)" {
    linux ($root)/live/vmlinuz boot=live hostname=SalamOS username=salamos
    initrd ($root)/live/initrd
}

menuentry "System Restart" { reboot }
menuentry "System Shutdown" { halt }
GEOF

if [[ -f "$PROJECT_ROOT/build/resources/salamos-grub.png" ]]; then
    cp "$PROJECT_ROOT/build/resources/salamos-grub.png" "$ISO_DIR/boot/grub/"
fi

# === Create EFI System Partition (ESP) image ===
echo "[07-create-iso] Creating EFI System Partition image..."

ESP_SIZE=8
ESP_IMG="$ISO_DIR/esp.img"  # Must be INSIDE ISO directory for xorriso -e

dd if=/dev/zero of="$ESP_IMG" bs=1M count=$ESP_SIZE
mkfs.vfat -F 12 "$ESP_IMG"

sudo mkdir -p /mnt/esp
sudo mount -o loop "$ESP_IMG" /mnt/esp
sudo mkdir -p /mnt/esp/EFI/BOOT
sudo mkdir -p /mnt/esp/boot/grub

# Create embedded early config for GRUB EFI standalone image
GRUB_EARLY_CFG="$ISO_DIR/grub-early.cfg"
cat > "$GRUB_EARLY_CFG" << 'EARLYEOF'
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

search --set=root --file /boot/grub/grub.cfg
set prefix=($root)/boot/grub

if [ -f /boot/grub/grub.cfg ]; then
  configfile /boot/grub/grub.cfg
fi

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

menuentry "SalamOS 2026.1 (Safe Mode)" {
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
EARLYEOF

if command -v grub-mkimage &>/dev/null; then
    echo "[07-create-iso] Generating GRUB standalone EFI image..."
    sudo grub-mkimage -O x86_64-efi \
        -o /mnt/esp/EFI/BOOT/BOOTX64.EFI \
        -p "/boot/grub" \
        -c "$GRUB_EARLY_CFG" \
        all_video boot btrfs cat chain configfile echo efifwsetup efi_gop \
        efi_uga fat font gfxmenu gfxterm gzio hfsplus iso9660 linux \
        loadenv loopback ls lsefi normal part_apple part_msdos part_gpt \
        png read reboot search search_fs_uuid search_fs_file search_label \
        squash4 test true video video_fb xfs

    # Copy grub.cfg and wallpaper to ESP for fallback
    sudo cp "$ISO_DIR/boot/grub/grub.cfg" /mnt/esp/boot/grub/grub.cfg
    sudo cp "$ISO_DIR/boot/grub/salamos-grub.png" /mnt/esp/boot/grub/salamos-grub.png

    # Also make EFI boot files visible in ISO filesystem tree
    # (xorriso warns about missing /EFI/BOOT; improves UEFI USB stick compatibility)
    mkdir -p "$ISO_DIR/EFI/BOOT"
    cp /mnt/esp/EFI/BOOT/BOOTX64.EFI "$ISO_DIR/EFI/BOOT/"

    echo "[07-create-iso] GRUB EFI image created successfully"
fi

sudo umount /mnt/esp
sudo rm -rf /mnt/esp

echo "ESP image created: $(ls -lh "$ESP_IMG")"

# === Create hybrid ISO with xorriso ===
echo "[07-create-iso] Generating hybrid ISO image..."

ISOLINUX_MBR="/usr/lib/ISOLINUX/isohdpfx.bin"
MOD_DATE=$(date +%Y%m%d%H%M%S00)

xorriso -as mkisofs \
    -iso-level 3 \
    -full-iso9660-filenames \
    -V "$ISO_VOLUME_ID" \
    -publisher "$ISO_publisher" \
    -A "$ISO_APPLICATION" \
    --modification-date="$MOD_DATE" \
    -isohybrid-mbr "$ISOLINUX_MBR" \
    -eltorito-boot isolinux/isolinux.bin \
    -no-emul-boot \
    -boot-load-size 4 \
    -boot-info-table \
    --eltorito-catalog isolinux/boot.cat \
    -eltorito-alt-boot \
    -e esp.img \
    -no-emul-boot \
    -isohybrid-gpt-basdat \
    -append_partition 2 0xef "$ESP_IMG" \
    -partition_offset 16 \
    -output "$OUTPUT_DIR/$ISO_NAME" \
    "$ISO_DIR"

echo "[07-create-iso] ISO created successfully!"
echo "[07-create-iso] ISO size: $(du -sh "$OUTPUT_DIR/$ISO_NAME" | cut -f1)"
