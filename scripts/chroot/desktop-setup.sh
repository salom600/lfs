#!/bin/bash
# SalamOS Desktop Setup - Configure desktop environment inside chroot
# ============================================
set -e
export PATH=/usr/sbin:/usr/bin:/sbin:/bin

# === Create user directories ===
mkdir -p /home/salamos/.config/openbox
mkdir -p /home/salamos/.config/tint2
mkdir -p /home/salamos/.config/jgmenu
mkdir -p /home/salamos/.config/nitrogen
mkdir -p /home/salamos/.config/dunst
mkdir -p /home/salamos/Desktop

# Copy default openbox configs if available
if [ -d /etc/xdg/openbox ]; then
  cp -a /etc/xdg/openbox/* /home/salamos/.config/openbox/
fi
if [ -f /etc/tint2/tint2rc ]; then
  cp /etc/tint2/tint2rc /home/salamos/.config/tint2/
fi

# === Wallpaper config ===
cat > /home/salamos/.config/nitrogen/nitrogen.cfg << 'NEOF'
[geometry]
posx=0
posy=0
width=1920
height=1080

[Nitrogen]
wallpaper=/usr/share/backgrounds/salamos/salamos-wallpaper.png
mode=CENTERED
NEOF

mkdir -p /root/.config/nitrogen
cp /home/salamos/.config/nitrogen/nitrogen.cfg /root/.config/nitrogen/

# === Desktop shortcuts (like Windows - one click to open apps) ===
cat > /home/salamos/Desktop/install-salamos.desktop << 'IEOF'
[Desktop Entry]
Type=Application
Name=Install SalamOS
Comment=Install SalamOS to hard drive
Exec=calamares
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
chmod +x /usr/local/bin/salamos-software-center

# Make desktop shortcuts trusted (show icons on desktop)
chmod +x /home/salamos/Desktop/*.desktop

# === Set ownership for user files ===
chown -R salamos:salamos /home/salamos/.config
chown -R salamos:salamos /home/salamos/Desktop

# === GTK theme settings ===
echo 'gtk-theme-name="SalamOS-Dark"' > /home/salamos/.gtkrc-2.0
echo 'gtk-icon-theme-name="Papirus"' >> /home/salamos/.gtkrc-2.0
echo 'gtk-font-name="Hack 10"' >> /home/salamos/.gtkrc-2.0
chown salamos:salamos /home/salamos/.gtkrc-2.0

mkdir -p /home/salamos/.config/gtk-3.0
cat > /home/salamos/.config/gtk-3.0/settings.ini << 'GEOF'
[Settings]
gtk-theme-name=SalamOS-Dark
gtk-icon-theme-name=Papirus
gtk-font-name=Hack 10
gtk-application-prefer-dark-theme=1
GEOF
chown -R salamos:salamos /home/salamos/.config/gtk-3.0

# === Dunst notification config ===
mkdir -p /home/salamos/.config/dunst
cat > /home/salamos/.config/dunst/dunstrc << 'DEOF'
[global]
font = Hack 10
format = "%s: %b"
sort = yes
indicate_hidden = yes
alignment = left
show_age_threshold = 60
word_wrap = yes
geometry = "300x5-30+20"
shrink = no
transparency = 10
padding = 8
horizontal_padding = 8
frame_color = "#0f3460"
frame_width = 1
separator_height = 2
separator_color = "#0f3460"

[urgency_low]
background = "#16213e"
foreground = "#e0e0e0"
timeout = 5

[urgency_normal]
background = "#0f3460"
foreground = "#ffffff"
timeout = 10

[urgency_critical]
background = "#e94560"
foreground = "#ffffff"
timeout = 0
DEOF
chown -R salamos:salamos /home/salamos/.config/dunst

echo "Desktop setup done"
