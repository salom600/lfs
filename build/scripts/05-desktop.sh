#!/bin/bash
# SalamOS Step 05: Desktop Setup - Configure Openbox desktop environment
# ============================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BUILD_ROOT="$(dirname "$SCRIPT_DIR")"
source "$BUILD_ROOT/config/vars"

CHROOT_DIR="$BUILD_ROOT/$CHROOT_DIR"

echo "[05-desktop] Setting up Openbox desktop environment..."

chroot "$CHROOT_DIR" /bin/bash << CHEOF

# Create Openbox autostart script
cat > /etc/xdg/openbox/autostart << AEOF
# SalamOS Openbox Autostart
# ============================

# Set wallpaper
nitrogen --restore &

# Start panel
tint2 &

# Start composite manager for smooth effects
picom --config /etc/picom.conf -b &

# Start application menu daemon
jgmenu --at-pointer --config-file=/etc/jgmenu/jgmenu.conf &

# Network Manager applet
nm-applet &

# Volume control
volumeicon-alsa &

# Power manager
xfce4-power-manager &

# Clipboard manager (optional, very light)
# clipit &

# Conky system monitor
conky -c /etc/conky/conky.conf &

AEOF

# Create Openbox menu (XML)
cat > /etc/xdg/openbox/menu.xml << MEOF
<?xml version="1.0" encoding="UTF-8"?>
<openbox_menu xmlns="http://openbox.org/3.4/menu">
  <menu id="root-menu" label="SalamOS">
    <menu id="applications" label="Applications">
      <menu id="internet" label="Internet">
        <item label="Firefox">
          <action name="Execute"><command>firefox-esr</command></action>
        </item>
      </menu>
      <menu id="utilities" label="Utilities">
        <item label="File Manager">
          <action name="Execute"><command>pcmanfm</command></action>
        </item>
        <item label="Terminal">
          <action name="Execute"><command>lxterminal</command></action>
        </item>
        <item label="Text Editor">
          <action name="Execute"><command>mousepad</command></action>
        </item>
        <item label="System Monitor">
          <action name="Execute"><command>htop</command></action>
        </item>
        <item label="Partition Manager">
          <action name="Execute"><command>gparted</command></action>
        </item>
        <item label="Screenshot">
          <action name="Execute"><command>scrot -d 3</command></action>
        </item>
      </menu>
      <menu id="settings" label="Settings">
        <item label="Openbox Configuration">
          <action name="Execute"><command>obconf</command></action>
        </item>
        <item label="Appearance">
          <action name="Execute"><command>lxappearance</command></action>
        </item>
        <item label="Wallpaper">
          <action name="Execute"><command>nitrogen /usr/share/backgrounds/salamos</command></action>
        </item>
        <item label="Network">
          <action name="Execute"><command>nm-connection-editor</command></action>
        </item>
        <item label="Audio">
          <action name="Execute"><command>pavucontrol-qt</command></action>
        </item>
        <item label="Rofi Launcher">
          <action name="Execute"><command>rofi -show run</command></action>
        </item>
        <item label="Reconfigure Openbox">
          <action name="Reconfigure"/>
        </item>
      </menu>
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

# Create Openbox rc.xml (window manager configuration)
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
      <name>Hack</name>
      <size>10</size>
      <weight>Bold</weight>
      <slant>Normal</slant>
    </font>
    <font place="InactiveWindow">
      <name>Hack</name>
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
    <keybind key="Super-a">
      <action name="ShowMenu"><menu>root-menu</menu></action>
    </keybind>
    <keybind key="Super-r">
      <action name="Execute"><command>rofi -show run</command></action>
    </keybind>
    <keybind key="Super-t">
      <action name="Execute"><command>lxterminal</command></action>
    </keybind>
    <keybind key="Super-f">
      <action name="Execute"><command>pcmanfm</command></action>
    </keybind>
    <keybind key="Super-w">
      <action name="Execute"><command>firefox-esr</command></action>
    </keybind>
    <keybind key="Super-e">
      <action name="Execute"><command>mousepad</command></action>
    </keybind>
    <keybind key="Super-l">
      <action name="Execute"><command>lightlock-command -l</command></action>
    </keybind>
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
    <keybind key="Alt-F4">
      <action name="Close"/>
    </keybind>
    <keybind key="Alt-Tab">
      <action name="NextWindow"><allDesktops>no</allDesktops><raise>yes</raise></action>
    </keybind>
    <keybind key="Alt-space">
      <action name="ShowMenu"><menu>client-menu</menu></action>
    </keybind>
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
      <mousebind button="Right" action="Press">
        <action name="ShowMenu"><menu>root-menu</menu></action>
      </mousebind>
      <mousebind button="Middle" action="Press">
        <action name="ShowDesktop"/>
      </mousebind>
      <mousebind button="Left" action="Press">
        <action name="ShowMenu"><menu>client-list-combined-menu</menu></action>
      </mousebind>
    </context>
  </mouse>
</openbox_config>
REOF

# Copy user-specific Openbox config
cp -a /etc/xdg/openbox/ /home/$DEFAULT_USER/.config/openbox/
chown -R $DEFAULT_USER:$DEFAULT_USER /home/$DEFAULT_USER/.config/openbox/

CHEOF

echo "[05-desktop] Desktop environment configured successfully"
