#!/bin/bash
# SalamOS Desktop Setup - Modern Professional Desktop Environment
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

# === Wallpaper config ===
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

# === PCManFM config - modern look ===
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
desktop_font = sans 10
show_documents = 0
show_trash = 0
show_mounts = 1
PEOF

# === Desktop shortcuts - Modern styled icons ===
cat > /home/salamos/Desktop/install-salamos.desktop << 'IEOF'
[Desktop Entry]
Type=Application
Name=Install SalamOS
Comment=Install SalamOS to hard drive
Exec=sudo calamares
Icon=system-software-install
Categories=System;
StartupNotify=true
IEOF

cat > /home/salamos/Desktop/software-center.desktop << 'SEOF'
[Desktop Entry]
Type=Application
Name=Software Center
Comment=Install applications with one click
Exec=salamos-software-center gui
Icon=system-software-install
Categories=System;
StartupNotify=true
SEOF

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

cat > /home/salamos/Desktop/terminal.desktop << 'TEOF'
[Desktop Entry]
Type=Application
Name=Terminal
Comment=Command Line
Exec=lxterminal
Icon=utilities-terminal
Categories=System;TerminalEmulator;
StartupNotify=true
TEOF

# Make Software Center executable
if [ -f /usr/local/bin/salamos-software-center ]; then
  chmod +x /usr/local/bin/salamos-software-center
fi

# Make desktop shortcuts trusted (show icons on desktop)
chmod +x /home/salamos/Desktop/*.desktop 2>/dev/null || true

# === Set ownership for ALL user files ===
chown -R salamos:salamos /home/salamos/.config
chown -R salamos:salamos /home/salamos/Desktop
chown -R salamos:salamos /home/salamos/Documents
chown -R salamos:salamos /home/salamos/Downloads
chown -R salamos:salamos /home/salamos/Music
chown -R salamos:salamos /home/salamos/Pictures
chown -R salamos:salamos /home/salamos/Videos

# === GTK theme settings - Modern font ===
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

# === Dunst notification config - Modern ===
cat > /home/salamos/.config/dunst/dunstrc << 'DEOF'
[global]
font = Noto Sans 10
format = "%s\n%b"
sort = yes
indicate_hidden = yes
alignment = center
show_age_threshold = 60
word_wrap = yes
geometry = "350x5-20+40"
shrink = no
transparency = 15
padding = 12
horizontal_padding = 12
frame_color = "#1f4068"
frame_width = 2
corner_radius = 8
separator_height = 4
separator_color = rgba(255,255,255,0.06)
progress_bar = true
progress_bar_height = 4
progress_bar_frame_width = 0
progress_bar_min_width = 150
progress_bar_max_width = 300

[urgency_low]
background = "#162447"
foreground = "#e8e8e8"
timeout = 5
corner_radius = 8

[urgency_normal]
background = "#1f4068"
foreground = "#ffffff"
timeout = 10
corner_radius = 8

[urgency_critical]
background = "#e43f5a"
foreground = "#ffffff"
timeout = 0
corner_radius = 8
DEOF
chown -R salamos:salamos /home/salamos/.config/dunst

echo "Desktop setup done"
