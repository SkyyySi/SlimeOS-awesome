local menu_parts = {}

menu_parts["Barrierefreiheit"] = {
	{"KMouseTool", "kmousetool -qwindowtitle KMouseTool", "/usr/share//icons/hicolor/16x16/apps/kmousetool.png" },
}

menu_parts["Bildung"] = {
	{"GeoGebra", "geogebra"},
	{"KTouch", "ktouch", "/usr/share//icons/hicolor/16x16/apps/ktouch.png" },
	{"LibreOffice Math", "libreoffice --math ", "/usr/share//icons/hicolor/16x16/apps/libreoffice-math.png" },
	{"Plots", "/usr/bin/flatpak run --branch=stable --arch=x86_64 --command=plots com.github.alexhuntley.Plots"},
}

menu_parts["Büro"] = {
	{"Dokumentenbetrachter", "evince "},
	{"GNOME LaTeX", "gnome-latex "},
	{"Kalender", "gnome-calendar "},
	{"Kontakte", "gnome-contacts"},
	{"LibreOffice", "libreoffice ", "/usr/share//icons/hicolor/16x16/apps/libreoffice-startcenter.png" },
	{"LibreOffice Base", "libreoffice --base ", "/usr/share//icons/hicolor/16x16/apps/libreoffice-base.png" },
	{"LibreOffice Calc", "libreoffice --calc ", "/usr/share//icons/hicolor/16x16/apps/libreoffice-calc.png" },
	{"LibreOffice Draw", "libreoffice --draw ", "/usr/share//icons/hicolor/16x16/apps/libreoffice-draw.png" },
	{"LibreOffice Impress", "libreoffice --impress ", "/usr/share//icons/hicolor/16x16/apps/libreoffice-impress.png" },
	{"LibreOffice Math", "libreoffice --math ", "/usr/share//icons/hicolor/16x16/apps/libreoffice-math.png" },
	{"LibreOffice Writer", "libreoffice --writer ", "/usr/share//icons/hicolor/16x16/apps/libreoffice-writer.png" },
	{"MarkText", "/usr/lib/marktext/marktext ", "/usr/share//icons/hicolor/16x16/apps/marktext.png" },
	{"Obsidian", "/usr/bin/obsidian ", "/usr/share/pixmaps/obsidian.png" },
	{"TeXstudio", "texstudio ", "/usr/share//icons/hicolor/16x16/apps/texstudio.png" },
}

menu_parts["Entwicklung"] = {
	{"BlueJ", "bluej ", "/usr/share//icons/hicolor/48x48/apps/bluej.png" },
	{"CMake", "cmake-gui ", "/usr/share//icons/hicolor/32x32/apps/CMakeSetup.png" },
	{"D-Feet", "d-feet"},
	{"D-Spy", "/usr/bin/flatpak run --branch=stable --arch=x86_64 --command=d-spy org.gnome.dspy"},
	{"DBeaver CE", "/usr/bin/flatpak run --branch=stable --arch=x86_64 --command=/app/dbeaver/dbeaver io.dbeaver.DBeaverCommunity", "/var/lib/flatpak/exports/share/icons/hicolor/16x16/apps/io.dbeaver.DBeaverCommunity.png" },
	{"Electron", "electron ", "/usr/share/pixmaps/electron.png" },
	{"Electron 18", "electron18 ", "/usr/share/pixmaps/electron18.png" },
	{"Electron 19", "electron19 ", "/usr/share/pixmaps/electron19.png" },
	{"Gaphor", "/usr/bin/flatpak run --branch=stable --arch=x86_64 --command=gaphor --file-forwarding org.gaphor.Gaphor @@  @@", "/var/lib/flatpak/exports/share/icons/hicolor/24x24/apps/org.gaphor.Gaphor.png" },
	{"Kate", "kate -b ", "/usr/share//icons/hicolor/16x16/apps/kate.png" },
	{"Kompare", "kompare -o ", "/usr/share//icons/hicolor/16x16/apps/kompare.png" },
	{"Micro", "xterm -e micro "},
	{"Qt Assistant", "assistant", "/usr/share//icons/hicolor/32x32/apps/assistant.png" },
	{"Qt Designer", "designer ", "/usr/share//icons/hicolor/128x128/apps/QtProject-designer.png" },
	{"Qt Linguist", "linguist ", "/usr/share//icons/hicolor/16x16/apps/linguist.png" },
	{"Qt QDBusViewer ", "qdbusviewer", "/usr/share//icons/hicolor/32x32/apps/qdbusviewer.png" },
	{"Sonixd", "/opt/sonixd-appimage/Sonixd-0.15.3-linux-x86_64.AppImage --no-sandbox ", "/usr/share//icons/hicolor/16x16/apps/sonixd.png" },
	{"UserFeedback-Konsole", "UserFeedbackConsole"},
	{"VSCodium", "/opt/vscodium-bin/bin/codium --no-sandbox --unity-launch ", "/usr/share/pixmaps/vscodium.png" },
	{"ipython", "xterm -e ipython", "/usr/share/pixmaps/ipython.png" },
}

menu_parts["Grafik"] = {
	{"Bildbetrachter", "eog "},
	{"Dokument-Scanner", "simple-scan"},
	{"Dokumentenbetrachter", "evince "},
	{"Flameshot", "/usr/bin/flameshot", "/usr/share//icons/hicolor/48x48/apps/org.flameshot.Flameshot.png" },
	{"Fotos", "gnome-photos"},
	{"GNU Image Manipulation Program", "gimp-2.10 ", "/usr/share//icons/hicolor/16x16/apps/gimp.png" },
	{"Gpick", "gpick ", "/usr/share//icons/hicolor/48x48/apps/gpick.png" },
	{"Gwenview", "gwenview ", "/usr/share//icons/hicolor/16x16/apps/gwenview.png" },
	{"Inkscape", "inkscape ", "/usr/share//icons/hicolor/16x16/apps/org.inkscape.Inkscape.png" },
	{"Krita", "krita ", "/usr/share//icons/hicolor/16x16/apps/krita.png" },
	{"LibreOffice Draw", "libreoffice --draw ", "/usr/share//icons/hicolor/16x16/apps/libreoffice-draw.png" },
	{"Pinta", "pinta ", "/usr/share//icons/hicolor/16x16/apps/pinta.png" },
	{"Skanlite", "skanlite", "/usr/share//icons/hicolor/48x48/apps/org.kde.skanlite.svg" },
	{"XDvi", "xdvi "},
	{"digiKam", "digikam -qwindowtitle digiKam", "/usr/share//icons/hicolor/16x16/apps/digikam.png" },
	{"showFoto", "showfoto -qwindowtitle showFoto ", "/usr/share//icons/hicolor/16x16/apps/showfoto.png" },
}

menu_parts["Internet"] = {
	{"Avahi SSH-Server-Browser", "/usr/bin/bssh"},
	{"Avahi VNC-Server-Browser", "/usr/bin/bvnc"},
	{"Discord", "/usr/bin/discord", "/usr/share/pixmaps/discord.png" },
	{"Ein verbundenes mit KDE Connect öffnen", "kdeconnect-handler --open "},
	{"Firefox", "/usr/lib/firefox/firefox ", "/usr/share//icons/hicolor/16x16/apps/firefox.png" },
	{"IM-Kontakte", "ktp-contactlist ", "/usr/share//icons/hicolor/16x16/apps/telepathy-kde.png" },
	{"Instant-Messenger-Protokollbetrachter", "ktp-log-viewer "},
	{"KDE Connect", "kdeconnect-app"},
	{"KDE Connect-SMS", "kdeconnect-sms"},
	{"KDE-Connect-Anzeige", "kdeconnect-indicator"},
	{"Steam (Native)", "/usr/bin/steam-native ", "/usr/share//icons/hicolor/16x16/apps/steam.png" },
	{"Steam (Runtime)", "/usr/bin/env GDK_SCALE=2 /usr/bin/steam-runtime ", "/usr/share//icons/hicolor/16x16/apps/steam.png" },
	{"Transmission (Qt)", "transmission-qt ", "/usr/share/pixmaps/transmission-qt.png" },
	{"discord-screenaudio", "/usr/bin/flatpak run --branch=stable --arch=x86_64 --command=discord-screenaudio de.shorsh.discord-screenaudio", "/var/lib/flatpak/exports/share/icons/hicolor/256x256/apps/de.shorsh.discord-screenaudio.png" },
}

menu_parts["Spiele"] = {
	{"Minen", "gnome-mines"},
	{"Prism Launcher", "prismlauncher"},
	{"Quadrapassel", "quadrapassel"},
	{"Steam (Native)", "/usr/bin/steam-native ", "/usr/share//icons/hicolor/16x16/apps/steam.png" },
	{"Steam (Runtime)", "/usr/bin/env GDK_SCALE=2 /usr/bin/steam-runtime ", "/usr/share//icons/hicolor/16x16/apps/steam.png" },
}

menu_parts["Systemwerkzeuge"] = {
	{"Avahi Zeroconf Browser", "/usr/bin/avahi-discover"},
	{"Betrachter für abgestürzte Prozesse", "drkonqi-coredump-gui"},
	{"Discover", "plasma-discover ", "/usr/share//icons/hicolor/16x16/apps/plasmadiscover.png" },
	{"Dolphin", "dolphin "},
	{"Druckerverwaltung", "/usr/bin/xdg-open http://localhost:631/", "/usr/share//icons/hicolor/16x16/apps/cups.png" },
	{"Festplattenbelegungsanalyse", "baobab "},
	{"Hardware Locality lstopo", "lstopo"},
	{"Htop", "xterm -e htop", "/usr/share/pixmaps/htop.png" },
	{"KDE-Partitionsverwaltung", "partitionmanager"},
	{"KWalletManager", "kwalletmanager5 ", "/usr/share//icons/hicolor/16x16/apps/kwalletmanager.png" },
	{"Konsole", "konsole"},
	{"OpenJDK Java 17 Console", "/usr/lib/jvm/java-17-openjdk/bin/jconsole", "/usr/share//icons/hicolor/16x16/apps/java17-openjdk.png" },
	{"OpenJDK Java 17 Shell", "xterm -e /usr/lib/jvm/java-17-openjdk/bin/jshell", "/usr/share//icons/hicolor/16x16/apps/java17-openjdk.png" },
	{"Protokolle", "gnome-logs"},
	{"Software", "gnome-software "},
	{"Systemmonitor", "plasma-systemmonitor"},
	{"Systemüberwachung", "gnome-system-monitor"},
	{"Terminal", "gnome-terminal"},
	{"UXTerm", "uxterm", "/usr/share/pixmaps/xterm-color_48x48.xpm" },
	{"Vala Panel", "vala-panel"},
	{"XTerm", "xterm", "/usr/share/pixmaps/xterm-color_48x48.xpm" },
	{"dconf-Editor", "dconf-editor"},
}

menu_parts["Unterhaltungsmedien"] = {
	{"Audacity", "env UBUNTU_MENUPROXY=0 audacity ", "/usr/share/pixmaps/audacity.xpm" },
	{"Blanket", "blanket"},
	{"Cheese", "cheese"},
	{"EasyTAG", "easytag ", "/usr/share//icons/hicolor/16x16/apps/easytag.png" },
	{"Jellyfin Media Player", "jellyfinmediaplayer"},
	{"Musik", "gnome-music"},
	{"OBS Studio", "obs", "/usr/share//icons/hicolor/128x128/apps/com.obsproject.Studio.png" },
	{"OpenShot Video Editor", "openshot-qt ", "/usr/share//icons/hicolor/64x64/apps/openshot-qt.png" },
	{"PulseAudio Equalizer", "pulseaudio-equalizer-gtk"},
	{"PulseAudio System Tray", "pasystray", "/usr/share/pixmaps/pasystray.png" },
	{"PulseAudio-Lautstärkeregler", "pavucontrol"},
	{"Qt V4L2 test Utility", "qv4l2", "/usr/share//icons/hicolor/16x16/apps/qv4l2.png" },
	{"Qt V4L2 video capture utility", "qvidcap", "/usr/share//icons/hicolor/16x16/apps/qvidcap.png" },
	{"QtAV Player", "Player -f "},
	{"QtAV QML Player", "QMLPlayer -f "},
	{"VLC Media Player", "/usr/bin/vlc --started-from-file ", "/usr/share//icons/hicolor/16x16/apps/vlc.png" },
	{"Videos", "totem "},
	{"Zrythm", "/usr/bin/flatpak run --branch=stable --arch=x86_64 --command=/app/bin/zrythm_launch org.zrythm.Zrythm"},
	{"mpv Media Player", "mpv --player-operation-mode=pseudo-gui -- ", "/usr/share//icons/hicolor/16x16/apps/mpv.png" },
}

menu_parts["Zubehör"] = {
	{"Archivverwaltung", "file-roller "},
	{"Ark", "ark ", "/usr/share//icons/hicolor/48x48/apps/ark.png" },
	{"Barrier", "barrier"},
	{"Bücher", "gnome-books"},
	{"Coolero", "/usr/bin/flatpak run --branch=stable --arch=x86_64 --command=coolero org.coolero.Coolero"},
	{"Dateien", "nautilus --new-window "},
	{"Emote", "emote", "///usr/share/icons/emote.svg" },
	{"Erweiterungen", "/usr/bin/gnome-extensions-app --gapplication-service"},
	{"Filelight", "filelight ", "/usr/share//icons/hicolor/16x16/apps/filelight.png" },
	{"Hilfe", "yelp "},
	{"KBackup", "kbackup ", "/usr/share//icons/hicolor/16x16/apps/kbackup.png" },
	{"KCalc", "kcalc"},
	{"KMouseTool", "kmousetool -qwindowtitle KMouseTool", "/usr/share//icons/hicolor/16x16/apps/kmousetool.png" },
	{"KWrite", "kwrite ", "/usr/share//icons/hicolor/16x16/apps/kwrite.png" },
	{"Karten", "gapplication launch org.gnome.Maps "},
	{"Kate", "kate -b ", "/usr/share//icons/hicolor/16x16/apps/kate.png" },
	{"Klipper", "klipper"},
	{"Kvantum Manager", "kvantummanager"},
	{"Laufwerke", "gnome-disks"},
	{"MarkText", "/usr/lib/marktext/marktext ", "/usr/share//icons/hicolor/16x16/apps/marktext.png" },
	{"Micro", "xterm -e micro "},
	{"Nextcloud Desktop-Synchronisationsclient", "nextcloud ", "/usr/share//icons/hicolor/16x16/apps/Nextcloud.png" },
	{"NormCap", "normcap "},
	{"Nostalgia", "/usr/bin/flatpak run --branch=stable --arch=x86_64 --command=nostalgia im.bernard.Nostalgia"},
	{"Optimierungen", "gnome-tweaks"},
	{"Schriften", "gnome-font-viewer "},
	{"Spectacle", "/usr/bin/spectacle"},
	{"Taschenrechner", "gnome-calculator"},
	{"Touché", "com.github.joseexposito.touche", "/usr/share//icons/hicolor/16x16/apps/com.github.joseexposito.touche.svg" },
	{"Uhren", "gnome-clocks"},
	{"VSCodium", "/opt/vscodium-bin/bin/codium --no-sandbox --unity-launch ", "/usr/share/pixmaps/vscodium.png" },
	{"Warp", "/usr/bin/flatpak run --branch=stable --arch=x86_64 --command=warp --file-forwarding app.drey.Warp @@u  @@"},
	{"Wetter", "gapplication launch org.gnome.Weather"},
	{"Zeichen", "/usr/bin/gnome-characters"},
	{"gedit", "gedit "},
	{"ipython", "xterm -e ipython", "/usr/share/pixmaps/ipython.png" },
	{"nitrogen", "nitrogen", "/usr/share//icons/hicolor/16x16/apps/nitrogen.png" },
	{"picom", "picom"},
}

local xdg_menu = {
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

return xdg_menu
