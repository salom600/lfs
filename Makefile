.PHONY: all build clean help

# SalamOS Build Makefile
# ============================================

DISTRO_NAME := SalamOS
DISTRO_VERSION := 2026.1

BUILD_DIR := build
CHROOT_DIR := build/chroot
ISO_DIR := build/iso
OUTPUT_DIR := build/output

SCRIPTS_DIR := build/scripts

help:
	@echo "SalamOS Build System"
	@echo "====================="
	@echo ""
	@echo "Targets:"
	@echo "  build      - Build full ISO"
	@echo "  clean      - Remove all build artifacts"
	@echo "  assets     - Generate wallpapers and logos"
	@echo "  help       - Show this help"
	@echo ""
	@echo "Individual steps:"
	@echo "  debootstrap  - Create base Debian system"
	@echo "  chroot       - Setup chroot environment"
	@echo "  packages     - Install packages"
	@echo "  customize    - Apply customizations"
	@echo "  desktop      - Setup desktop"
	@echo "  cleanup      - Cleanup and optimize"
	@echo "  iso          - Create bootable ISO"

all: build

build:
	sudo bash $(SCRIPTS_DIR)/build-all.sh

debootstrap:
	sudo bash $(SCRIPTS_DIR)/build-all.sh 01-debootstrap

chroot:
	sudo bash $(SCRIPTS_DIR)/build-all.sh 02-chroot-setup

packages:
	sudo bash $(SCRIPTS_DIR)/build-all.sh 03-packages

customize:
	sudo bash $(SCRIPTS_DIR)/build-all.sh 04-customize

desktop:
	sudo bash $(SCRIPTS_DIR)/build-all.sh 05-desktop

cleanup:
	sudo bash $(SCRIPTS_DIR)/build-all.sh 06-cleanup

iso:
	sudo bash $(SCRIPTS_DIR)/build-all.sh 07-create-iso

assets:
	python3 scripts/generate-salamos-assets.py

clean:
	sudo rm -rf $(CHROOT_DIR) $(ISO_DIR) $(OUTPUT_DIR)
	@echo "Build artifacts removed"
