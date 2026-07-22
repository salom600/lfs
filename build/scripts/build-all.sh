#!/bin/bash
# SalamOS Master Build Script
# Orchestrates the entire build process
# ============================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BUILD_ROOT="$(dirname "$SCRIPT_DIR")"
PROJECT_ROOT="$(dirname "$BUILD_ROOT")"

# Load configuration
source "$BUILD_ROOT/config/vars"

# Color output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info()  { echo -e "${BLUE}[INFO]${NC} $1"; }
log_ok()    { echo -e "${GREEN}[OK]${NC} $1"; }
log_warn()  { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_err()   { echo -e "${RED}[ERROR]${NC} $1"; }

# Build steps (in order)
STEPS=(
    "01-debootstrap:Create base Debian system"
    "02-chroot-setup:Setup chroot environment"
    "03-packages:Install and remove packages"
    "04-customize:Apply SalamOS customizations"
    "05-desktop:Setup desktop environment"
    "06-cleanup:Cleanup and optimize"
    "07-create-iso:Create bootable ISO"
)

# Check dependencies
check_deps() {
    log_info "Checking build dependencies..."
    local deps=("debootstrap" "squashfs-tools" "xorriso" "grub-pc-bin" "mtools" "dosfstools")
    for dep in "${deps[@]}"; do
        if ! command -v "$dep" &>/dev/null; then
            log_err "Missing dependency: $dep"
            log_info "Installing missing dependencies..."
            apt-get update
            apt-get install -y "${deps[@]}"
            break
        fi
    done
    log_ok "All dependencies satisfied"
}

# Run a build step
run_step() {
    local step_name="$1"
    local step_desc="$2"
    local step_script="$SCRIPT_DIR/${step_name}.sh"
    
    if [[ ! -f "$step_script" ]]; then
        log_err "Script not found: $step_script"
        return 1
    fi
    
    log_info ">>> Step: $step_desc"
    if bash "$step_script"; then
        log_ok ">>> Completed: $step_desc"
        return 0
    else
        log_err ">>> Failed: $step_desc"
        return 1
    fi
}

# Main build
main() {
    log_info "============================================"
    log_info " SalamOS Build System"
    log_info " Version: $DISTRO_VERSION"
    log_info " Base: $BASE_DISTRO $BASE_SUITE ($BASE_ARCH)"
    log_info "============================================"
    
    check_deps
    
    # If a specific step is requested, run only that
    if [[ -n "${1:-}" ]]; then
        local target_step="$1"
        for step_info in "${STEPS[@]}"; do
            local step_name="${step_info%%:*}"
            local step_desc="${step_info##*:}"
            if [[ "$step_name" == "$target_step" ]]; then
                run_step "$step_name" "$step_desc"
                exit $?
            fi
        done
        log_err "Unknown step: $target_step"
        exit 1
    fi
    
    # Run all steps
    for step_info in "${STEPS[@]}"; do
        local step_name="${step_info%%:*}"
        local step_desc="${step_info##*:}"
        if ! run_step "$step_name" "$step_desc"; then
            log_err "Build failed at step: $step_name"
            exit 1
        fi
    done
    
    # Verify ISO size
    local iso_path="$BUILD_ROOT/output/$ISO_NAME"
    if [[ -f "$iso_path" ]]; then
        local iso_size_mb=$(du -m "$iso_path" | cut -f1)
        log_info "ISO size: ${iso_size_mb}MB"
        if [[ $iso_size_mb -gt $MAX_ISO_SIZE_MB ]]; then
            log_warn "ISO exceeds target size (${iso_size_mb}MB > ${MAX_ISO_SIZE_MB}MB)"
        else
            log_ok "ISO within target size (${iso_size_mb}MB <= ${MAX_ISO_SIZE_MB}MB)"
        fi
    fi
    
    log_ok "============================================"
    log_ok " Build completed successfully!"
    log_ok " ISO: $iso_path"
    log_ok "============================================"
}

main "${@:-}"
