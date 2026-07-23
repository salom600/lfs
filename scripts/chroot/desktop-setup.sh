#!/bin/bash
# SalamOS Desktop Setup - 2026 Modern Professional Desktop
# Stunning wallpaper + Modern icons + Glass effects + Windows-like UX
# ============================================
set -e
export PATH=/usr/sbin:/usr/bin:/sbin:/bin

# === Create ALL user directories ===
mkdir -p /home/salamos/.config/openbox
mkdir -p /home/salamos/.config/tint2
mkdir -p /home/salamos/.config/jgmenu
mkdir -p /home/salamos/.config/nitrogen
mkdir -p /home/salamos/.config/dunst
mkdir -p /home/salamos/.config/gtk-3.0
mkdir -p /home/salamos/.config/picom
mkdir -p /home/salamos/.config/pcmanfm
mkdir -p /home/salamos/.config/rofi
mkdir -p /home/salamos/Desktop
mkdir -p /home/salamos/Documents
mkdir -p /home/salamos/Downloads
mkdir -p /home/salamos/Music
mkdir -p /home/salamos/Pictures
mkdir -p /home/salamos/Videos
mkdir -p /home/salamos/Public
mkdir -p /home/salamos/Templates

# Copy default openbox configs if available
if [ -d /etc/xdg/openbox ]; then
  cp -a /etc/xdg/openbox/* /home/salamos/.config/openbox/
fi
if [ -f /etc/tint2/tint2rc ]; then
  cp /etc/tint2/tint2rc /home/salamos/.config/tint2/
fi

# === XDG user-dirs config ===
cat > /home/salamos/.config/user-dirs.dirs << 'XEOF'
XDG_DESKTOP_DIR="$HOME/Desktop"
XDG_DOCUMENTS_DIR="$HOME/Documents"
XDG_DOWNLOAD_DIR="$HOME/Downloads"
XDG_MUSIC_DIR="$HOME/Music"
XDG_PICTURES_DIR="$HOME/Pictures"
XDG_VIDEOS_DIR="$HOME/Videos"
XDG_PUBLICSHARE_DIR="$HOME/Public"
XDG_TEMPLATES_DIR="$HOME/Templates"
XEOF

# === Wallpaper config - Point to new stunning wallpaper ===
cat > /home/salamos/.config/nitrogen/nitrogen.cfg << 'NEOF'
[geometry]
posx=0
posy=0
width=1920
height=1080

[Nitrogen]
wallpaper=/usr/share/backgrounds/salamos/salamos-wallpaper.png
mode=Scaled
NEOF

mkdir -p /root/.config/nitrogen
cp /home/salamos/.config/nitrogen/nitrogen.cfg /root/.config/nitrogen/

# === PCManFM config - Modern look with icon view ===
mkdir -p /home/salamos/.config/pcmanfm/default
cat > /home/salamos/.config/pcmanfm/default/pcmanfm.conf << 'PEOF'
[config]
show_hidden_files = 0
show_side_pane = 1
side_pane_mode = places
view_mode = icon
icon_size = 48
thumbnail_size = 128
show_status_bar = 1
sort_by = name
sort_type = ascending

[desktop]
show_desktop = 1
show_wallpaper = 1
wallpaper = /usr/share/backgrounds/salamos/salamos-wallpaper.png
wallpaper_mode = stretch
desktop_font = Noto Sans 10
show_documents = 0
show_trash = 1
show_mounts = 1
PEOF

# === Desktop shortcuts - Modern Windows-like icons ===
# These .desktop files will appear as clickable icons on the desktop

# Install SalamOS (most important - prominent)
cat > /home/salamos/Desktop/install-salamos.desktop << 'IEOF'
[Desktop Entry]
Type=Application
Name=Install SalamOS
Comment=Install SalamOS to your hard drive permanently
Exec=sudo calamares
Icon=system-software-install
Categories=System;
StartupNotify=true
IEOF

# Software Center (Windows-like app store)
cat > /home/salamos/Desktop/software-center.desktop << 'SEOF'
[Desktop Entry]
Type=Application
Name=Software Center
Comment=Browse and install applications with one click
Exec=salamos-software-center gui
Icon=papirus-appstore
Categories=System;
StartupNotify=true
SEOF

# Firefox (Web Browser - like Edge on Windows)
cat > /home/salamos/Desktop/firefox.desktop << 'FEOF'
[Desktop Entry]
Type=Application
Name=Firefox
Comment=Web Browser
Exec=firefox-esr
Icon=firefox
Categories=Network;WebBrowser;
StartupNotify=true
FEOF

# Files (File Manager - like Explorer on Windows)
cat > /home/salamos/Desktop/file-manager.desktop << 'FMEOF'
[Desktop Entry]
Type=Application
Name=Files
Comment=File Manager
Exec=pcmanfm
Icon=system-file-manager
Categories=System;FileManager;
StartupNotify=true
FMEOF

# Terminal (Command Line - like CMD/PowerShell on Windows)
cat > /home/salamos/Desktop/terminal.desktop << 'TEOF'
[Desktop Entry]
Type=Application
Name=Terminal
Comment=Command Line Terminal
Exec=lxterminal
Icon=utilities-terminal
Categories=System;TerminalEmulator;
StartupNotify=true
TEOF

# Settings (like Windows Settings)
cat > /home/salamos/Desktop/settings.desktop << 'SETEOF'
[Desktop Entry]
Type=Application
Name=Settings
Comment=System Settings and Appearance
Exec=lxappearance
Icon=preferences-desktop
Categories=Settings;
StartupNotify=true
SETEOF

# Package Manager (Advanced)
cat > /home/salamos/Desktop/synaptic.desktop << 'SYEOF'
[Desktop Entry]
Type=Application
Name=Package Manager
Comment=Advanced package management
Exec=synaptic
Icon=synaptic
Categories=System;
StartupNotify=true
SYEOF

# Make Software Center executable
if [ -f /usr/local/bin/salamos-software-center ]; then
  chmod +x /usr/local/bin/salamos-software-center
fi

# Make desktop shortcuts trusted (show proper icons on desktop)
chmod +x /home/salamos/Desktop/*.desktop 2>/dev/null || true

# === Set ownership for ALL user files ===
chown -R salamos:salamos /home/salamos/.config
chown -R salamos:salamos /home/salamos/Desktop
chown -R salamos:salamos /home/salamos/Documents
chown -R salamos:salamos /home/salamos/Downloads
chown -R salamos:salamos /home/salamos/Music
chown -R salamos:salamos /home/salamos/Pictures
chown -R salamos:salamos /home/salamos/Videos

# === GTK theme settings - Modern 2026 fonts and icons ===
cat > /home/salamos/.gtkrc-2.0 << 'GEOF2'
gtk-theme-name="SalamOS-Dark"
gtk-icon-theme-name="Papirus"
gtk-font-name="Noto Sans 10"
gtk-toolbar-style=2
gtk-toolbar-icon-size=2
gtk-button-images=0
gtk-menu-images=0
GEOF2
chown salamos:salamos /home/salamos/.gtkrc-2.0

cat > /home/salamos/.config/gtk-3.0/settings.ini << 'GEOF3'
[Settings]
gtk-theme-name=SalamOS-Dark
gtk-icon-theme-name=Papirus
gtk-font-name=Noto Sans 10
gtk-application-prefer-dark-theme=1
gtk-toolbar-style=2
gtk-toolbar-icon-size=2
gtk-button-images=0
gtk-menu-images=0
gtk-primary-button-wants-center=1
GEOF3
chown -R salamos:salamos /home/salamos/.config/gtk-3.0

# === Dunst notification config - Modern frosted glass ===
cat > /home/salamos/.config/dunst/dunstrc << 'DEOF'
[global]
font = Noto Sans 10
format = "%s\n%b"
sort = yes
indicate_hidden = yes
alignment = center
show_age_threshold = 60
word_wrap = yes
geometry = "400x5-20+40"
shrink = no
transparency = 10
padding = 14
horizontal_padding = 14
frame_color = "#7c3aed"
frame_width = 2
corner_radius = 10
separator_height = 6
separator_color = rgba(255,255,255,0.06)
progress_bar = true
progress_bar_height = 4
progress_bar_frame_width = 0
progress_bar_min_width = 180
progress_bar_max_width = 350

[urgency_low]
background = "#16213e"
foreground = "#dce6ff"
timeout = 5
corner_radius = 10

[urgency_normal]
background = "#2d468c"
foreground = "#ffffff"
timeout = 10
corner_radius = 10

[urgency_critical]
background = "#e94560"
foreground = "#ffffff"
timeout = 0
corner_radius = 10
DEOF
chown -R salamos:salamos /home/salamos/.config/dunst

# === Rofi config - Modern app launcher (like Windows Search) ===
cat > /home/salamos/.config/rofi/config.rasi << 'REOF'
configuration {
    modi: "drun,run";
    font: "Noto Sans 10";
    show-icons: true;
    icon-theme: "Papirus";
    display-drun: "Apps";
    display-run: "Run";
    drun-display-format: "{name}";
    disable-history: false;
    sidebar-mode: true;
    scroll-method: 0;
}

@theme "/dev/null"

window {
    background-color: #0d1123ee;
    border: 2px;
    border-color: #7c3aed;
    border-radius: 12px;
    padding: 12px;
    width: 35%;
}

entry {
    background-color: #16213e;
    border: 2px;
    border-color: #2d468c;
    border-radius: 8px;
    padding: 8px;
    text-color: #dce6ff;
    placeholder: "Search...";
    placeholder-color: #3a3a4e;
}

listview {
    background-color: #0d1123;
    border: 0px;
    padding: 8px;
    lines: 8;
}

element {
    background-color: #0d1123;
    border: 0px;
    border-radius: 8px;
    padding: 8px;
    text-color: #dce6ff;
}

element selected {
    background-color: #7c3aed;
    border: 0px;
    border-radius: 8px;
    text-color: #ffffff;
}

element-icon {
    size: 2ch;
}

element-text {
    padding: 4px;
}

sidebar {
    background-color: #16213e;
    border: 0px;
}

button selected {
    background-color: #7c3aed;
    text-color: #ffffff;
    border-radius: 8px;
}
REOF
chown -R salamos:salamos /home/salamos/.config/rofi

echo "Desktop setup done - 2026 Modern Edition"
