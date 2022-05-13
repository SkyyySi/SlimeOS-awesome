local menu_parts = {}

menu_parts["Archlinux"] = {
	{"AUR", "xdg-open https://aur.archlinux.org", "/usr/share/icons/hicolor/32x32/apps/arch-logo.png" },
	{"Bugs", "xdg-open https://bugs.archlinux.org", "/usr/share/icons/hicolor/32x32/apps/arch-logo.png" },
	{"Developers", "xdg-open http://www.archlinux.org/developers/", "/usr/share/icons/hicolor/32x32/apps/arch-logo.png" },
	{"Documentation", "xdg-open https://wiki.archlinux.org/index.php/Official_Arch_Linux_Install_Guide", "/usr/share/icons/hicolor/32x32/apps/arch-logo.png" },
	{"Donate", "xdg-open http://www.archlinux.org/donate/", "/usr/share/icons/hicolor/32x32/apps/arch-logo.png" },
	{"Forum", "xdg-open https://bbs.archlinux.org", "/usr/share/icons/hicolor/32x32/apps/arch-logo.png" },
	{"Homepage", "xdg-open http://www.archlinux.org", "/usr/share/icons/hicolor/32x32/apps/arch-logo.png" },
	{"SVN", "xdg-open http://projects.archlinux.org/svntogit/", "/usr/share/icons/hicolor/32x32/apps/arch-logo.png" },
	{"Schwag", "xdg-open http://www.zazzle.com/archlinux/", "/usr/share/icons/hicolor/32x32/apps/arch-logo.png" },
	{"Wiki", "xdg-open https://wiki.archlinux.org", "/usr/share/icons/hicolor/32x32/apps/arch-logo.png" },
}

menu_parts["Barrierefreiheit"] = {
	{"Onboard", "onboard", "/usr/share/icons/hicolor/16x16/apps/onboard.png" },
}

menu_parts["Bildung"] = {
	{"LibreOffice Math", "libreoffice --math ", "/usr/share/icons/hicolor/16x16/apps/libreoffice-math.png" },
	{"xmaxima", "xmaxima", "/usr/share/pixmaps/net.sourceforge.maxima.png" },
}

menu_parts["Büro"] = {
	{"Aufgaben", "io.elementary.tasks", "/usr/share/icons/hicolor/16x16/apps/io.elementary.tasks.svg" },
	{"Dokumentenbetrachter", "evince "},
	{"Kalender", "gnome-calendar "},
	{"Kalender", "io.elementary.calendar ", "/usr/share/icons/hicolor/16x16/apps/io.elementary.calendar.svg" },
	{"Kontakte", "gnome-contacts"},
	{"LibreOffice", "libreoffice ", "/usr/share/icons/hicolor/16x16/apps/libreoffice-startcenter.png" },
	{"LibreOffice Base", "libreoffice --base ", "/usr/share/icons/hicolor/16x16/apps/libreoffice-base.png" },
	{"LibreOffice Calc", "libreoffice --calc ", "/usr/share/icons/hicolor/16x16/apps/libreoffice-calc.png" },
	{"LibreOffice Draw", "libreoffice --draw ", "/usr/share/icons/hicolor/16x16/apps/libreoffice-draw.png" },
	{"LibreOffice Impress", "libreoffice --impress ", "/usr/share/icons/hicolor/16x16/apps/libreoffice-impress.png" },
	{"LibreOffice Math", "libreoffice --math ", "/usr/share/icons/hicolor/16x16/apps/libreoffice-math.png" },
	{"LibreOffice Writer", "libreoffice --writer ", "/usr/share/icons/hicolor/16x16/apps/libreoffice-writer.png" },
	{"MarkText", "/usr/lib/marktext/marktext ", "/usr/share/icons/hicolor/16x16/apps/marktext.png" },
	{"Minder", "/usr/bin/flatpak run --branch=stable --arch=x86_64 --command=com.github.phase1geo.minder --file-forwarding com.github.phase1geo.minder @@  @@", "/var/lib/flatpak/exports/share/icons/hicolor/16x16/apps/com.github.phase1geo.minder.svg" },
	{"Minder", "com.github.phase1geo.minder ", "/var/lib/flatpak/exports/share/icons/hicolor/16x16/apps/com.github.phase1geo.minder.svg" },
	{"Wörterbuch", "xfce4-dict", "/usr/share/icons/hicolor/16x16/apps/org.xfce.Dictionary.png" },
}

menu_parts["Entwicklung"] = {
	{"Boxen", "gnome-boxes "},
	{"CMake", "cmake-gui ", "/usr/share/icons/hicolor/32x32/apps/CMakeSetup.png" },
	{"Code", "io.elementary.code ", "/usr/share/icons/hicolor/16x16/apps/io.elementary.code.svg" },
	{"Code - OSS", "/usr/bin/code-oss --unity-launch ", "/usr/share/pixmaps/com.visualstudio.code.oss.png" },
	{"Cppcheck", "cppcheck-gui", "/usr/share/icons/hicolor/64x64/apps/cppcheck-gui.png" },
	{"Cuttlefish", "cuttlefish"},
	{"Electron", "electron ", "/usr/share/pixmaps/electron.png" },
	{"Electron 11", "electron11 ", "/usr/share/pixmaps/electron11.png" },
	{"Electron 12", "electron12 ", "/usr/share/pixmaps/electron12.png" },
	{"Electron 13", "electron13 ", "/usr/share/pixmaps/electron13.png" },
	{"Electron 15", "electron15 ", "/usr/share/pixmaps/electron15.png" },
	{"Electron 17", "electron17 ", "/usr/share/pixmaps/electron17.png" },
	{"Emacs", "emacs ", "/usr/share/icons/hicolor/16x16/apps/emacs.png" },
	{"Emacs (Client)", "sh -c \"if [ -n \\\"\\$*\\\" ]; then exec emacsclient --alternate-editor= --display=\\\"\\$DISPLAY\\\" \\\"\\$@\\\"; else exec emacsclient --alternate-editor= --create-frame; fi\" placeholder ", "/usr/share/icons/hicolor/16x16/apps/emacs.png" },
	{"FLUID", "fluid ", "/usr/share/icons/hicolor/32x32/apps/fluid.png" },
	{"GHex", "ghex "},
	{"GdaBrowser", "gda-browser-5.0", "/usr/share/pixmaps/gda-browser-5.0.png" },
	{"Glade", "glade "},
	{"Globaler Plasma-Designexplorer", "lookandfeelexplorer"},
	{"Greenfoot", "greenfoot ", "/usr/share/icons/hicolor/256x256/apps/greenfoot.png" },
	{"Icon Browser", "yad-icon-browser", "/usr/share/icons/hicolor/16x16/apps/yad.png" },
	{"IntelliJ IDEA Community Edition", "/usr/bin/idea ", "/usr/share/pixmaps/idea.png" },
	{"Micro", "xterm -e micro "},
	{"Minder", "/usr/bin/flatpak run --branch=stable --arch=x86_64 --command=com.github.phase1geo.minder --file-forwarding com.github.phase1geo.minder @@  @@", "/var/lib/flatpak/exports/share/icons/hicolor/16x16/apps/com.github.phase1geo.minder.svg" },
	{"Minder", "com.github.phase1geo.minder ", "/var/lib/flatpak/exports/share/icons/hicolor/16x16/apps/com.github.phase1geo.minder.svg" },
	{"MonoDevelop", "monodevelop ", "/usr/share/icons/hicolor/16x16/apps/monodevelop.png" },
	{"Plasma-Datenquellen-Betrachter", "plasmaengineexplorer"},
	{"Plasma-Designexplorer", "plasmathemeexplorer"},
	{"PyCharm Community Edition", "/usr/bin/pycharm ", "/usr/share/pixmaps/pycharm.png" },
	{"Qt Assistant", "assistant", "/usr/share/icons/hicolor/32x32/apps/assistant.png" },
	{"Qt Designer", "designer ", "/usr/share/icons/hicolor/128x128/apps/QtProject-designer.png" },
	{"Qt Linguist", "linguist ", "/usr/share/icons/hicolor/16x16/apps/linguist.png" },
	{"Qt QDBusViewer ", "qdbusviewer", "/usr/share/icons/hicolor/32x32/apps/qdbusviewer.png" },
	{"Scratch", "scratch", "/usr/share/icons/hicolor/32x32/apps/scratch.png" },
	{"Unity", "/usr/bin/unity-editor", "/usr/share/icons/hicolor/256x256/apps/unity-editor-icon.png" },
	{"Unity Hub", "/opt/unityhub/unityhub ", "/usr/share/icons/hicolor/16x16/apps/unityhub.png" },
	{"UserFeedback-Konsole", "UserFeedbackConsole"},
	{"VSCodium", "/usr/share/vscodium-bin/bin/codium --no-sandbox --unity-launch ", "/usr/share/pixmaps/vscodium.png" },
	{"ZeroBrane Studio", "zbstudio ", "/usr/share/icons/hicolor/16x16/apps/zbstudio.png" },
	{"distcc monitor", "distccmon-gnome", "/usr/share/pixmaps/distccmon-gnome.png" },
	{"ipython", "xterm -e ipython", "/usr/share/pixmaps/ipython.png" },
	{"wxLua Editor", "wxLua ", "/usr/share/icons/wxlualogo.xpm" },
}

menu_parts["Grafik"] = {
	{"Adobe Flash Player Standalone", "/usr/bin/flashplayer"},
	{"Aseprite", "aseprite ", "/usr/share/icons/hicolor/16x16/apps/aseprite.png" },
	{"Bildbetrachter", "gpicview ", "/usr/share/icons/hicolor/48x48/apps/gpicview.png" },
	{"Bildbetrachter", "eog "},
	{"Blender", "blender "},
	{"Dokument-Scanner", "simple-scan"},
	{"Dokumentenbetrachter", "evince "},
	{"Fotos", "io.elementary.photos ", "/usr/share/icons/hicolor/16x16/apps/io.elementary.photos.svg" },
	{"GNU Image Manipulation Program", "gimp-2.10 ", "/usr/share/icons/hicolor/16x16/apps/gimp.png" },
	{"Gpick", "gpick ", "/usr/share/icons/hicolor/48x48/apps/gpick.png" },
	{"Inkscape", "inkscape ", "/usr/share/icons/hicolor/16x16/apps/org.inkscape.Inkscape.png" },
	{"Krita", "krita ", "/usr/share/icons/hicolor/16x16/apps/krita.png" },
	{"LXImage", "lximage-qt ", "/usr/share/icons/hicolor/48x48/apps/lximage-qt.png" },
	{"LibreOffice Draw", "libreoffice --draw ", "/usr/share/icons/hicolor/16x16/apps/libreoffice-draw.png" },
	{"Ristretto-Bildbetrachter", "ristretto ", "/usr/share/icons/hicolor/16x16/apps/org.xfce.ristretto.png" },
	{"ScreenGrab", "screengrab"},
	{"XDvi", "xdvi "},
	{"gThumb", "gthumb ", "/usr/share/icons/hicolor/16x16/apps/org.gnome.gThumb.png" },
}

menu_parts["Internet"] = {
	{"Avahi SSH-Server-Browser", "/usr/bin/bssh"},
	{"Avahi VNC-Server-Browser", "/usr/bin/bvnc"},
	{"Brave", "brave ", "/usr/share/icons/hicolor/16x16/apps/brave-desktop.png" },
	{"Discord", "/usr/bin/discord", "/usr/share/pixmaps/discord.png" },
	{"Ein verbundenes mit KDE Connect öffnen", "kdeconnect-handler --open "},
	{"FileZilla", "filezilla", "/usr/share/icons/hicolor/16x16/apps/filezilla.png" },
	{"Firefox", "/usr/lib/firefox/firefox ", "/usr/share/icons/hicolor/16x16/apps/firefox.png" },
	{"HexChat", "hexchat --existing ", "/usr/share/icons/hicolor/48x48/apps/io.github.Hexchat.png" },
	{"KDE Connect", "kdeconnect-app"},
	{"KDE Connect-SMS", "kdeconnect-sms"},
	{"KDE-Connect-Anzeige", "kdeconnect-indicator"},
	{"Mail", "io.elementary.mail ", "/usr/share/icons/hicolor/16x16/apps/io.elementary.mail.svg" },
	{"Steam (Native)", "/usr/bin/steam-native ", "/usr/share/icons/hicolor/16x16/apps/steam.png" },
	{"Steam (Runtime)", "/usr/bin/steam-runtime ", "/usr/share/icons/hicolor/16x16/apps/steam.png" },
	{"TeamViewer", "/opt/teamviewer/tv_bin/script/teamviewer", "/usr/share/icons/hicolor/16x16/apps/TeamViewer.png" },
	{"TigerVNC-Betrachter", "/usr/bin/vncviewer", "/usr/share/icons/hicolor/16x16/apps/tigervnc.png" },
	{"Transmission", "transmission-gtk ", "/usr/share/pixmaps/transmission.png" },
	{"Verbindungen", "gnome-connections "},
	{"Web", "epiphany "},
}

menu_parts["Spiele"] = {
	{"Flashpoint Infinity", "/usr/lib/flashpoint-infinity/flashpoint-launcher ", "/usr/share/icons/hicolor/16x16/apps/flashpoint-launcher.png" },
	{"Lutris", "lutris ", "/usr/share/icons/hicolor/16x16/apps/lutris.png" },
	{"Mindustry", "/usr/bin/flatpak run --branch=stable --arch=x86_64 --command=mindustry.sh com.github.Anuken.Mindustry"},
	{"Minecraft Launcher", "minecraft-launcher"},
	{"PolyMC", "polymc"},
	{"Powder Toy", "/usr/bin/flatpak run --branch=stable --arch=x86_64 --command=powder uk.co.powdertoy.tpt", "/var/lib/flatpak/exports/share/icons/hicolor/16x16/apps/uk.co.powdertoy.tpt.png" },
	{"Steam (Native)", "/usr/bin/steam-native ", "/usr/share/icons/hicolor/16x16/apps/steam.png" },
	{"Steam (Runtime)", "/usr/bin/steam-runtime ", "/usr/share/icons/hicolor/16x16/apps/steam.png" },
	{"mGBA", "mgba-qt ", "/usr/share/pixmaps/mgba.png" },
}

menu_parts["Systemwerkzeuge"] = {
	{"Alacritty", "alacritty", "/usr/share/pixmaps/Alacritty.svg" },
	{"Android File Transfer (MTP)", "android-file-transfer"},
	{"Avahi Zeroconf Browser", "/usr/bin/avahi-discover"},
	{"Boxen", "gnome-boxes "},
	{"Dateien", "io.elementary.files "},
	{"Discover", "plasma-discover ", "/usr/share/icons/hicolor/16x16/apps/plasmadiscover.png" },
	{"Dolphin", "dolphin "},
	{"Druckerverwaltung", "/usr/bin/xdg-open http://localhost:631/", "/usr/share/icons/hicolor/16x16/apps/cups.png" },
	{"Festplattenbelegungsanalyse", "baobab "},
	{"GParted", "/usr/bin/gparted ", "/usr/share/icons/hicolor/16x16/apps/gparted.png" },
	{"Hardware Locality lstopo", "lstopo"},
	{"Htop", "xterm -e htop", "/usr/share/pixmaps/htop.png" },
	{"KDE-Partitionsverwaltung", "partitionmanager"},
	{"KSysGuard", "ksysguard "},
	{"Konsole", "konsole"},
	{"LSHW", "/usr/sbin/gtk-lshw", "///usr/share/lshw/artwork/logo.svg" },
	{"LXTerminal", "lxterminal", "/usr/share/icons/hicolor/128x128/apps/lxterminal.png" },
	{"Massenumbenennen", "thunar --bulk-rename ", "/usr/share/icons/hicolor/16x16/apps/org.xfce.thunar.png" },
	{"OpenJDK Java 11 Console", "/usr/lib/jvm/java-11-openjdk/bin/jconsole", "/usr/share/icons/hicolor/16x16/apps/java11-openjdk.png" },
	{"OpenJDK Java 11 Shell", "xterm -e /usr/lib/jvm/java-11-openjdk/bin/jshell", "/usr/share/icons/hicolor/16x16/apps/java11-openjdk.png" },
	{"Oracle VM VirtualBox", "VirtualBox ", "/usr/share/icons/hicolor/16x16/mimetypes/virtualbox.png" },
	{"PCManFM Dateimanager", "pcmanfm "},
	{"Protokolle", "gnome-logs"},
	{"QTerminal", "qterminal"},
	{"QTerminal herabhängend", "qterminal --drop"},
	{"Sensorbetrachter", "xfce4-sensors", "/usr/share/icons/hicolor/24x24/apps/xfce-sensors.png" },
	{"Software", "gnome-software "},
	{"Systemeinstellungen", "io.elementary.switchboard "},
	{"Systemmonitor", "plasma-systemmonitor"},
	{"Systemüberwachung", "gnome-system-monitor"},
	{"Taskmanager", "lxtask"},
	{"Taskmanager", "xfce4-taskmanager", "/usr/share/icons/hicolor/16x16/apps/org.xfce.taskmanager.png" },
	{"Terminal", "gnome-terminal"},
	{"Terminal", "io.elementary.terminal"},
	{"Thunar-Dateiverwaltung", "thunar ", "/usr/share/icons/hicolor/16x16/apps/org.xfce.thunar.png" },
	{"Tilix", "tilix"},
	{"Tint2", "tint2"},
	{"UXTerm", "uxterm", "/usr/share/pixmaps/xterm-color_48x48.xpm" },
	{"VMware Player", "/usr/bin/vmplayer ", "/usr/share/icons/hicolor/16x16/apps/vmware-player.png" },
	{"VMware Workstation", "/usr/bin/vmware ", "/usr/share/icons/hicolor/16x16/apps/vmware-workstation.png" },
	{"Vala Panel", "vala-panel"},
	{"Virtual Network Editor", "/usr/bin/vmware-netcfg", "/usr/share/icons/hicolor/16x16/apps/vmware-netcfg.png" },
	{"Virtuelle Maschinenverwaltung", "virt-manager", "/usr/share/icons/hicolor/16x16/apps/virt-manager.png" },
	{"WezTerm", "wezterm", "/usr/share/icons/hicolor/128x128/apps/org.wezfurlong.wezterm.png" },
	{"XTerm", "xterm", "/usr/share/pixmaps/xterm-color_48x48.xpm" },
	{"Xfce-Terminal", "xfce4-terminal", "/usr/share/icons/hicolor/16x16/apps/org.xfce.terminal.png" },
	{"dconf-Editor", "dconf-editor", "/usr/share/icons/hicolor/16x16/apps/ca.desrt.dconf-editor.png" },
	{"fish", "xterm -e fish", "/usr/share/pixmaps/fish.png" },
	{"gmrun", "gmrun", "/usr/share/pixmaps/gmrun.png" },
	{"kitty", "kitty", "/usr/share/icons/hicolor/256x256/apps/kitty.png" },
	{"nnn", "xterm -e nnn", "/usr/share/icons/hicolor/64x64/apps/nnn.png" },
}

menu_parts["Unterhaltungsmedien"] = {
	{"Adobe Flash Player Standalone", "/usr/bin/flashplayer"},
	{"DeaDBeeF", "deadbeef ", "/usr/share/icons/hicolor/16x16/apps/deadbeef.png" },
	{"EasyTAG", "easytag ", "/usr/share/icons/hicolor/16x16/apps/easytag.png" },
	{"Echomixer", "echomixer", "/usr/share/icons/hicolor/48x48/apps/echomixer.png" },
	{"Envy24 Control", "envy24control", "/usr/share/icons/hicolor/48x48/apps/envy24control.png" },
	{"HDAJackRetask", "hdajackretask"},
	{"HDSPConf", "hdspconf", "/usr/share/icons/hicolor/48x48/apps/hdspconf.png" },
	{"HDSPMixer", "hdspmixer", "/usr/share/icons/hicolor/48x48/apps/hdspmixer.png" },
	{"Hwmixvolume", "hwmixvolume", "/usr/share/icons/hicolor/48x48/apps/hwmixvolume.png" },
	{"Jellyfin Media Player", "jellyfinmediaplayer"},
	{"Kamera", "io.elementary.camera", "/usr/share/icons/hicolor/16x16/apps/io.elementary.camera.svg" },
	{"Kdenlive", "kdenlive ", "/usr/share/icons/hicolor/16x16/apps/kdenlive.png" },
	{"Kodi", "kodi", "/usr/share/icons/hicolor/16x16/apps/kodi.png" },
	{"Kwave-Sound-Editor", "kwave "},
	{"LXMusic simple music player", "lxmusic", "/usr/share/icons/hicolor/128x128/apps/lxmusic.png" },
	{"MakeMKV", "makemkv", "/usr/share/icons/hicolor/16x16/apps/makemkv.png" },
	{"Musik", "gnome-music"},
	{"Musik", "io.elementary.music ", "/usr/share/icons/hicolor/16x16/apps/io.elementary.music.svg" },
	{"New Session Manager (Legacy GUI)", "nsm-legacy-gui"},
	{"OBS Studio", "obs", "/usr/share/icons/hicolor/128x128/apps/com.obsproject.Studio.png" },
	{"OSD Lyrics", "osdlyrics", "/usr/share/icons/hicolor/64x64/apps/osdlyrics.png" },
	{"OpenShot Video Editor", "openshot-qt ", "/usr/share/icons/hicolor/64x64/apps/openshot-qt.png" },
	{"Parole-Medienspieler", "parole ", "/usr/share/icons/hicolor/16x16/apps/org.xfce.parole.png" },
	{"PulseAudio Equalizer", "pulseaudio-equalizer-gtk"},
	{"PulseAudio System Tray", "pasystray", "/usr/share/pixmaps/pasystray.png" },
	{"PulseAudio Volume Control", "pavucontrol-qt"},
	{"PulseAudio-Lautstärkeregler", "pavucontrol"},
	{"Qt V4L2 test Utility", "qv4l2", "/usr/share/icons/hicolor/16x16/apps/qv4l2.png" },
	{"Qt V4L2 video capture utility", "qvidcap", "/usr/share/icons/hicolor/16x16/apps/qvidcap.png" },
	{"Sonixd", "sonixd", "/usr/share/pixmaps/sonixd.png" },
	{"Soundux", "/opt/soundux/soundux", "/usr/share/pixmaps/soundux.png" },
	{"Spek", "spek ", "/usr/share/icons/hicolor/16x16/apps/spek.png" },
	{"Tonaufzeichner", "gnome-sound-recorder"},
	{"VLC Media Player", "/usr/bin/vlc --started-from-file ", "/usr/share/icons/hicolor/16x16/apps/vlc.png" },
	{"Videos", "io.elementary.videos ", "/usr/share/icons/hicolor/16x16/apps/io.elementary.videos.svg" },
	{"Volume Icon", "volumeicon"},
	{"Xfburn", "xfburn"},
	{"mpv Media Player", "mpv --player-operation-mode=pseudo-gui -- ", "/usr/share/icons/hicolor/16x16/apps/mpv.png" },
}

menu_parts["Zubehör"] = {
	{"Albert", "albert"},
	{"Anwendungsfinder", "xfce4-appfinder", "/usr/share/icons/hicolor/16x16/apps/org.xfce.appfinder.png" },
	{"Archivverwaltung", "file-roller "},
	{"Azote", "azote", "/usr/share/pixmaps/azote.svg" },
	{"Bildbetrachter", "gpicview ", "/usr/share/icons/hicolor/48x48/apps/gpicview.png" },
	{"Bildschirmfoto", "io.elementary.screenshot", "/usr/share/icons/hicolor/16x16/apps/io.elementary.screenshot.svg" },
	{"Bildschirmfoto", "gnome-screenshot --interactive"},
	{"Bildschirmfoto", "xfce4-screenshooter", "/usr/share/icons/hicolor/16x16/apps/org.xfce.screenshooter.png" },
	{"Bücher", "gnome-books"},
	{"Dateien", "nautilus --new-window "},
	{"Dokumente", "gnome-documents"},
	{"Erweiterungen", "/usr/bin/gnome-extensions-app --gapplication-service"},
	{"Hilfe", "yelp "},
	{"Karten", "gapplication launch org.gnome.Maps "},
	{"Klipper", "klipper"},
	{"Kupfer", "kupfer ", "/usr/share/icons/hicolor/22x22/apps/kupfer.png" },
	{"Kvantum Manager", "kvantummanager"},
	{"LXQt Archiver", "lxqt-archiver "},
	{"Laufwerke", "gnome-disks"},
	{"Launchy", "launchy ", "/usr/share/pixmaps/launchy_icon.png" },
	{"MATE-Schriftanzeiger", "mate-font-viewer "},
	{"MarkText", "/usr/lib/marktext/marktext ", "/usr/share/icons/hicolor/16x16/apps/marktext.png" },
	{"Marker", "marker "},
	{"Micro", "xterm -e micro "},
	{"Minder", "com.github.phase1geo.minder ", "/var/lib/flatpak/exports/share/icons/hicolor/16x16/apps/com.github.phase1geo.minder.svg" },
	{"Mousepad", "mousepad ", "/usr/share/icons/hicolor/16x16/apps/org.xfce.mousepad.png" },
	{"Neovim", "xterm -e nvim ", "/usr/share/icons/hicolor/128x128/apps/nvim.png" },
	{"Nextcloud Desktop-Synchronisationsclient", "nextcloud", "/usr/share/icons/hicolor/16x16/apps/Nextcloud.png" },
	{"Notizen", "xfce4-notes", "/usr/share/icons/hicolor/16x16/apps/xfce4-notes-plugin.png" },
	{"Onboard", "onboard", "/usr/share/icons/hicolor/16x16/apps/onboard.png" },
	{"Optimierungen", "gnome-tweaks"},
	{"PCManFM-Qt", "pcmanfm-qt "},
	{"Plank", "plank", "/usr/share/icons/hicolor/16x16/apps/plank.svg" },
	{"PlayOnLinux", "playonlinux ", "/usr/share/pixmaps/playonlinux.png" },
	{"Rechner", "io.elementary.calculator", "/usr/share/icons/hicolor/16x16/apps/io.elementary.calculator.svg" },
	{"Redshift", "redshift-gtk"},
	{"Schriften", "gnome-font-viewer "},
	{"Taschenrechner", "gnome-calculator"},
	{"Uhren", "gnome-clocks"},
	{"Ulauncher", "env GDK_BACKEND=x11 /usr/bin/ulauncher --hide-window", "/usr/share/icons/hicolor/48x48/apps/ulauncher.svg" },
	{"VSCodium", "/usr/share/vscodium-bin/bin/codium --no-sandbox --unity-launch ", "/usr/share/pixmaps/vscodium.png" },
	{"Verbindungen", "gnome-connections "},
	{"Vim", "xterm -e vim ", "/usr/share/icons/hicolor/48x48/apps/gvim.png" },
	{"Wetter", "gapplication launch org.gnome.Weather"},
	{"Winetricks", "winetricks --gui"},
	{"Xarchiver", "xarchiver ", "/usr/share/icons/hicolor/16x16/apps/xarchiver.png" },
	{"Xfburn", "xfburn"},
	{"Zeichen", "/usr/bin/gnome-characters"},
	{"Zeichentabelle", "gucharmap"},
	{"Zwischenablageverwaltung", "xfce4-clipman", "/usr/share/icons/hicolor/16x16/apps/xfce4-clipman-plugin.png" },
	{"gedit", "gedit "},
	{"ipython", "xterm -e ipython", "/usr/share/pixmaps/ipython.png" },
	{"nitrogen", "nitrogen", "/usr/share/icons/hicolor/16x16/apps/nitrogen.png" },
	{"pentablet", "/usr/lib/pentablet/pentablet.sh", "///usr/share/icons/pentablet.png" },
}

local xdg_menu = {
	{"Archlinux", menu_parts["Archlinux"]},
	{"Barrierefreiheit", menu_parts["Barrierefreiheit"]},
	{"Bildung", menu_parts["Bildung"]},
	{"Büro", menu_parts["Büro"]},
	{"Entwicklung", menu_parts["Entwicklung"]},
	{"Grafik", menu_parts["Grafik"]},
	{"Internet", menu_parts["Internet"]},
	{"Spiele", menu_parts["Spiele"]},
	{"Systemwerkzeuge", menu_parts["Systemwerkzeuge"]},
	{"Unterhaltungsmedien", menu_parts["Unterhaltungsmedien"]},
	{"Zubehör", menu_parts["Zubehör"]},
}

return menu_parts
