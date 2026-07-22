# SalamOS

> Ultra-lightweight professional Linux distribution — built for speed, simplicity, and style.

## Overview

SalamOS is a custom Linux distribution designed to be as lightweight as possible while maintaining a professional, polished user experience. It strips away everything unnecessary and delivers only what you actually need.

### Key Principles

- **Maximum Lightness**: Idle RAM usage target ~150MB, ISO size target <500MB
- **Zero Bloat**: No pre-installed office suite, games, printing services, or snap/flatpak infrastructure
- **Professional Desktop**: Custom dark theme with a unique identity — not a generic XFCE/LXDE spin
- **Smooth & Fast**: Openbox WM + tint2 panel for the fastest possible desktop experience
- **Built on Debian Bookworm**: Rock-solid stability from the most trusted Linux base

## Desktop Environment

SalamOS uses a custom desktop setup that is fundamentally different from mainstream distributions:

| Component | Choice | Why |
|-----------|--------|-----|
| Window Manager | Openbox | Lightest functional WM, fully customizable |
| Panel | tint2 | Minimal resource usage, clean design |
| Menu | jgmenu + Rofi | Fast application launcher with search |
| Display Manager | LightDM | Lightweight login screen |
| Compositor | picom | Smooth window effects without heavy GPU usage |
| System Monitor | Conky | Always-visible minimal system stats |

## Keyboard Shortcuts

| Shortcut | Action |
|----------|--------|
| Super+A | Application menu |
| Super+R | Rofi launcher (search & run) |
| Super+T | Terminal |
| Super+F | File manager |
| Super+W | Browser |
| Super+E | Text editor |
| Super+L | Lock screen |
| Alt+Tab | Switch windows |
| Right-click desktop | Context menu |

## Build System

SalamOS is built automatically using **GitHub Actions**. Every push to the `main` branch triggers a full ISO build.

### Build Process

1. **Debootstrap** — Create minimal Debian Bookworm base system (variant: minbase)
2. **Chroot Setup** — Configure hostname, locale, timezone, user accounts
3. **Package Installation** — Install only essential packages (no recommends/suggests)
4. **Customization** — Apply SalamOS branding, theme, and configurations
5. **Desktop Setup** — Configure Openbox, tint2, jgmenu, picom, conky
6. **Cleanup** — Remove docs, unused locales, zero free space for compression
7. **ISO Creation** — Generate squashfs + bootable ISO with GRUB (BIOS+UEFI)

### Build Locally

```bash
# Clone the repository
git clone https://github.com/salom600/lfs.git
cd lfs

# Make scripts executable
chmod +x build/scripts/*.sh

# Run full build (requires root/debootstrap)
sudo bash build/scripts/build-all.sh

# Or run individual steps
sudo bash build/scripts/build-all.sh 01-debootstrap
```

### Requirements

- Debian/Ubuntu host system
- debootstrap, squashfs-tools, xorriso, grub-pc-bin
- ~10GB free disk space
- Root access for chroot operations

## Theme & Design

SalamOS features a custom **SalamOS-Dark** theme:

| Color | Hex | Usage |
|-------|-----|-------|
| Background | #1a1a2e | Main background |
| Surface | #16213e | Cards, panels |
| Primary | #0f3460 | Active elements, headerbar |
| Accent | #e94560 | Highlights, active buttons |
| Text | #e0e0e0 | Normal text |
| Bright Text | #ffffff | Active/selected text |

The theme is applied consistently across:
- GTK 2/3 applications
- Openbox window decorations
- tint2 panel
- jgmenu application menu
- LightDM greeter
- GRUB boot screen

## Included Software

### Essential
- **Firefox ESR** — Web browser (Arabic + English locales)
- **PCManFM** — File manager
- **LXTerminal** — Terminal emulator
- **Mousepad** — Text editor
- **GParted** — Partition manager

### System
- **NetworkManager** — Network management with GUI
- **PulseAudio** — Audio system with volume control
- **UFW** — Firewall (enabled by default)
- **TLP** — Power management optimization
- **LightDM** — Login manager

### Utilities
- **htop** — Process viewer
- **nano/vim** — Console editors
- **curl/wget** — Download tools
- **conky** — Desktop system monitor
- **scrot** — Screenshot tool

## Languages

- English (default)
- Arabic (with keyboard toggle: Alt+Shift)

## License

SalamOS is built from Debian packages, each under their respective licenses. The SalamOS-specific configuration files, themes, and build scripts are released under the MIT License.
