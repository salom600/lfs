#!/bin/bash
# SalamOS Step 05: Desktop Setup - 2026 Modern Professional Edition
# Configure Openbox desktop environment with modern design
# ============================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BUILD_ROOT="$(dirname "$SCRIPT_DIR")"
source "$BUILD_ROOT/config/vars"

CHROOT_DIR="$BUILD_ROOT/$CHROOT_DIR"

echo "[05-desktop] Setting up Openbox desktop environment - 2026 Edition..."

chroot "$CHROOT_DIR" /bin/bash << CHEOF

# === Openbox autostart script - Modern 2026 ===
cat > /etc/xdg/openbox/autostart << AEOF
# SalamOS Openbox Autostart - 2026 Modern Edition
# ============================================

# Set wallpaper (first - so desktop looks great immediately)
nitrogen --restore &

# Start picom compositor (blur + shadows + rounded corners)
picom --config /etc/picom.conf -b &

# Start tint2 panel (modern Windows 11-style taskbar)
tint2 &

# Start notification daemon (modern dunst with glassmorphism)
dunst &

# Network Manager applet (WiFi icon in tray)
nm-applet &

# Volume control (speaker icon in tray)
volumeicon-alsa &

# Conky system monitor (top-right elegant display)
(sleep 3 && conky -c /etc/conky/conky.conf) &

AEOF

# === Openbox menu (XML) - Modern categorized like Windows Start Menu ===
cat > /etc/xdg/openbox/menu.xml << MEOF
<?xml version="1.0" encoding="UTF-8"?>
<openbox_menu xmlns="http://openbox.org/3.4/menu">
  <menu id="root-menu" label="SalamOS">
    <separator label="SalamOS 2026.1"/>
    <menu id="internet" label="Internet">
      <item label="Firefox">
        <action name="Execute"><command>firefox-esr</command></action>
      </item>
    </menu>
    <menu id="utilities" label="Utilities">
      <item label="Files">
        <action name="Execute"><command>pcmanfm</command></action>
      </item>
      <item label="Terminal">
        <action name="Execute"><command>lxterminal</command></action>
      </item>
      <item label="Text Editor">
        <action name="Execute"><command>mousepad</command></action>
      </item>
      <item label="Screenshot">
        <action name="Execute"><command>scrot -d 3</command></action>
      </item>
    </menu>
    <menu id="system" label="System">
      <item label="Install SalamOS">
        <action name="Execute"><command>sudo calamares</command></action>
      </item>
      <item label="Software Center">
        <action name="Execute"><command>salamos-software-center gui</command></action>
      </item>
      <item label="Package Manager">
        <action name="Execute"><command>synaptic</command></action>
      </item>
      <item label="System Monitor">
        <action name="Execute"><command>htop</command></action>
      </item>
      <item label="Partition Manager">
        <action name="Execute"><command>gparted</command></action>
      </item>
    </menu>
    <menu id="settings" label="Settings">
      <item label="Appearance">
        <action name="Execute"><command>lxappearance</command></action>
      </item>
      <item label="Openbox Config">
        <action name="Execute"><command>obconf</command></action>
      </item>
      <item label="Wallpaper">
        <action name="Execute"><command>nitrogen /usr/share/backgrounds/salamos</command></action>
      </item>
      <item label="Network">
        <action name="Execute"><command>nm-connection-editor</command></action>
      </item>
      <item label="App Launcher">
        <action name="Execute"><command>rofi -show drun</command></action>
      </item>
      <item label="Reconfigure Openbox">
        <action name="Reconfigure"/>
      </item>
    </menu>
    <separator/>
    <item label="Lock Screen">
      <action name="Execute"><command>lightlock-command -l</command></action>
    </item>
    <separator/>
    <item label="Logout">
      <action name="Exit"/>
    </item>
    <item label="Reboot">
      <action name="Execute"><command>systemctl reboot</command></action>
    </item>
    <item label="Shutdown">
      <action name="Execute"><command>systemctl poweroff</command></action>
    </item>
  </menu>
</openbox_menu>
MEOF

# === Openbox rc.xml - Modern 2026 configuration ===
cat > /etc/xdg/openbox/rc.xml << REOF
<?xml version="1.0" encoding="UTF-8"?>
<openbox_config xmlns="http://openbox.org/3.4/rc" version="1">
  <resistance>
    <strength>10</strength>
    <screen_edge_strength>20</screen_edge_strength>
  </resistance>
  
  <focus>
    <focusNew>yes</focusNew>
    <followMouse>no</followMouse>
    <focusLast>yes</focusLast>
    <underMouse>no</underMouse>
  </focus>
  
  <placement>
    <policy>Smart</policy>
    <center>yes</center>
    <monitor>Active</monitor>
  </placement>
  
  <theme>
    <name>SalamOS-Dark</name>
    <titleLayout>NLIMC</titleLayout>
    <keepBorder>yes</keepBorder>
    <animateIconify>yes</animateIconify>
    <font place="ActiveWindow">
      <name>Noto Sans</name>
      <size>10</size>
      <weight>Bold</weight>
      <slant>Normal</slant>
    </font>
    <font place="InactiveWindow">
      <name>Noto Sans</name>
      <size>10</size>
      <weight>Normal</weight>
      <slant>Normal</slant>
    </font>
  </theme>
  
  <desktops>
    <number>2</number>
    <firstdesk>1</firstdesk>
    <names>
      <name>Main</name>
      <name>Work</name>
    </names>
    <popupTime>875</popupTime>
  </desktops>
  
  <resize>
    <drawContents>yes</drawContents>
    <popupShow>Never</popupShow>
  </resize>
  
  <margins>
    <top>0</top>
    <bottom>0</bottom>
    <left>0</left>
    <right>0</right>
  </margins>
  
  <keyboard>
    <!-- Super+A: Open jgmenu (Start Menu like Windows) -->
    <keybind key="Super-a">
      <action name="Execute"><command>jgmenu --at-pointer --config-file=/etc/jgmenu/jgmenu.conf</command></action>
    </keybind>
    <!-- Super+R: Open rofi launcher (like Windows Search) -->
    <keybind key="Super-r">
      <action name="Execute"><command>rofi -show drun</command></action>
    </keybind>
    <!-- Super+T: Open terminal -->
    <keybind key="Super-t">
      <action name="Execute"><command>lxterminal</command></action>
    </keybind>
    <!-- Super+F: Open file manager -->
    <keybind key="Super-f">
      <action name="Execute"><command>pcmanfm</command></action>
    </keybind>
    <!-- Super+W: Open web browser -->
    <keybind key="Super-w">
      <action name="Execute"><command>firefox-esr</command></action>
    </keybind>
    <!-- Super+E: Open text editor -->
    <keybind key="Super-e">
      <action name="Execute"><command>mousepad</command></action>
    </keybind>
    <!-- Super+L: Lock screen -->
    <keybind key="Super-l">
      <action name="Execute"><command>lightlock-command -l</command></action>
    </keybind>
    <!-- Super+Left/Right/Up/Down: Move window to edge -->
    <keybind key="Super-Left">
      <action name="MoveToEdge"><direction>left</direction></action>
    </keybind>
    <keybind key="Super-Right">
      <action name="MoveToEdge"><direction>right</direction></action>
    </keybind>
    <keybind key="Super-Up">
      <action name="MoveToEdge"><direction>top</direction></action>
    </keybind>
    <keybind key="Super-Down">
      <action name="MoveToEdge"><direction>bottom</direction></action>
    </keybind>
    <!-- Alt+F4: Close window -->
    <keybind key="Alt-F4">
      <action name="Close"/>
    </keybind>
    <!-- Alt+Tab: Switch windows -->
    <keybind key="Alt-Tab">
      <action name="NextWindow"><allDesktops>no</allDesktops><raise>yes</raise></action>
    </keybind>
    <!-- Alt+Space: Window menu -->
    <keybind key="Alt-space">
      <action name="ShowMenu"><menu>client-menu</menu></action>
    </keybind>
    <!-- Ctrl+Alt+Left/Right: Switch desktop -->
    <keybind key="C-A-Left">
      <action name="DesktopLeft"><wrap>yes</wrap></action>
    </keybind>
    <keybind key="C-A-Right">
      <action name="DesktopRight"><wrap>yes</wrap></action>
    </keybind>
  </keyboard>
  
  <mouse>
    <dragThreshold>8</dragThreshold>
    <doubleClickTime>200</doubleClickTime>
    <screenEdgeWarpTime>400</screenEdgeWarpTime>
    <context name="Root">
      <!-- Right-click on desktop: Show jgmenu (Start Menu) -->
      <mousebind button="Right" action="Press">
        <action name="Execute"><command>jgmenu --at-pointer --config-file=/etc/jgmenu/jgmenu.conf</command></action>
      </mousebind>
      <!-- Middle-click on desktop: Show desktop -->
      <mousebind button="Middle" action="Press">
        <action name="ShowDesktop"/>
      </mousebind>
      <!-- Left-click on desktop: Open rofi launcher -->
      <mousebind button="Left" action="Press">
        <action name="Execute"><command>rofi -show drun</command></action>
      </mousebind>
    </context>
  </mouse>
</openbox_config>
REOF

# Copy user-specific Openbox config
cp -a /etc/xdg/openbox/ /home/$DEFAULT_USER/.config/openbox/
chown -R $DEFAULT_USER:$DEFAULT_USER /home/$DEFAULT_USER/.config/openbox/

CHEOF

echo "[05-desktop] Desktop environment configured - 2026 Modern Edition"
