local menu_parts = {}

menu_parts["Barrierefreiheit"] = {
	{"KMouseTool", "kmousetool -qwindowtitle KMouseTool", "/usr/share//icons/hicolor/16x16/apps/kmousetool.png" },
}

menu_parts["Bildung"] = {
	{"KTouch", "ktouch", "/usr/share//icons/hicolor/16x16/apps/ktouch.png" },
	{"LibreOffice Math", "libreoffice --math ", "/usr/share//icons/hicolor/16x16/apps/libreoffice-math.png" },
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
	{"Boxen", "gnome-boxes "},
	{"CMake", "cmake-gui ", "/usr/share//icons/hicolor/32x32/apps/CMakeSetup.png" },
	{"D-Feet", "d-feet"},
	{"Electron 18", "electron18 ", "/usr/share/pixmaps/electron18.png" },
	{"Electron 19", "electron19 ", "/usr/share/pixmaps/electron19.png" },
	{"Kate", "kate -b ", "/usr/share//icons/hicolor/16x16/apps/kate.png" },
	{"Kompare", "kompare -o ", "/usr/share//icons/hicolor/16x16/apps/kompare.png" },
	{"Micro", "xterm -e micro "},
	{"Qt Assistant", "assistant", "/usr/share//icons/hicolor/32x32/apps/assistant.png" },
	{"Qt Designer", "designer ", "/usr/share//icons/hicolor/128x128/apps/QtProject-designer.png" },
	{"Qt Linguist", "linguist ", "/usr/share//icons/hicolor/16x16/apps/linguist.png" },
	{"Qt QDBusViewer ", "qdbusviewer", "/usr/share//icons/hicolor/32x32/apps/qdbusviewer.png" },
	{"UserFeedback-Konsole", "UserFeedbackConsole"},
	{"VSCodium", "/opt/vscodium-bin/bin/codium --no-sandbox --unity-launch ", "/usr/share/pixmaps/vscodium.png" },
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
	{"digiKam", "digikam -qwindowtitle digiKam", "/usr/share//icons/hicolor/16x16/apps/digikam.png" },
	{"showFoto", "showfoto -qwindowtitle showFoto ", "/usr/share//icons/hicolor/16x16/apps/showfoto.png" },
}

menu_parts["Internet"] = {
	{"Avahi SSH-Server-Browser", "/usr/bin/bssh"},
	{"Avahi VNC-Server-Browser", "/usr/bin/bvnc"},
	{"Discord", "/usr/bin/discord", "/usr/share/pixmaps/discord.png" },
	{"Ein verbundenes mit KDE Connect öffnen", "kdeconnect-handler --open "},
	{"Firefox", "firefox ", "/usr/share//icons/hicolor/16x16/apps/firefox.png" },
	{"IM-Kontakte", "ktp-contactlist ", "/usr/share//icons/hicolor/16x16/apps/telepathy-kde.png" },
	{"Instant-Messenger-Protokollbetrachter", "ktp-log-viewer "},
	{"KDE Connect", "kdeconnect-app"},
	{"KDE Connect-SMS", "kdeconnect-sms"},
	{"KDE-Connect-Anzeige", "kdeconnect-indicator"},
}

menu_parts["Systemwerkzeuge"] = {
	{"Avahi Zeroconf Browser", "/usr/bin/avahi-discover"},
	{"Boxen", "gnome-boxes "},
	{"Crashed Processes Viewer", "drkonqi-coredump-gui"},
	{"Discover", "plasma-discover ", "/usr/share//icons/hicolor/16x16/apps/plasmadiscover.png" },
	{"Dolphin", "dolphin "},
	{"Festplattenbelegungsanalyse", "baobab "},
	{"Hardware Locality lstopo", "lstopo"},
	{"Htop", "xterm -e htop", "/usr/share/pixmaps/htop.png" },
	{"KDE-Partitionsverwaltung", "partitionmanager"},
	{"KWalletManager", "kwalletmanager5 ", "/usr/share//icons/hicolor/16x16/apps/kwalletmanager.png" },
	{"Konsole", "konsole"},
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
	{"Cheese", "cheese"},
	{"Jellyfin Media Player", "jellyfinmediaplayer"},
	{"Musik", "gnome-music"},
	{"PulseAudio System Tray", "pasystray", "/usr/share/pixmaps/pasystray.png" },
	{"PulseAudio-Lautstärkeregler", "pavucontrol"},
	{"Qt V4L2 test Utility", "qv4l2", "/usr/share//icons/hicolor/16x16/apps/qv4l2.png" },
	{"Qt V4L2 video capture utility", "qvidcap", "/usr/share//icons/hicolor/16x16/apps/qvidcap.png" },
	{"QtAV Player", "Player -f "},
	{"QtAV QML Player", "QMLPlayer -f "},
	{"VLC Media Player", "/usr/bin/vlc --started-from-file ", "/usr/share//icons/hicolor/16x16/apps/vlc.png" },
	{"Videos", "totem "},
	{"mpv Media Player", "mpv --player-operation-mode=pseudo-gui -- ", "/usr/share//icons/hicolor/16x16/apps/mpv.png" },
}

menu_parts["Zubehör"] = {
	{"Archivverwaltung", "file-roller "},
	{"Ark", "ark ", "/usr/share//icons/hicolor/48x48/apps/ark.png" },
	{"Bücher", "gnome-books"},
	{"Dateien", "nautilus --new-window "},
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
	{"Optimierungen", "gnome-tweaks"},
	{"Schriften", "gnome-font-viewer "},
	{"Spectacle", "/usr/bin/spectacle"},
	{"Taschenrechner", "gnome-calculator"},
	{"Touché", "com.github.joseexposito.touche", "/usr/share//icons/hicolor/16x16/apps/com.github.joseexposito.touche.svg" },
	{"Uhren", "gnome-clocks"},
	{"VSCodium", "/opt/vscodium-bin/bin/codium --no-sandbox --unity-launch ", "/usr/share/pixmaps/vscodium.png" },
	{"Wetter", "gapplication launch org.gnome.Weather"},
	{"Zeichen", "/usr/bin/gnome-characters"},
	{"gedit", "gedit "},
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
	{"Systemwerkzeuge", menu_parts["Systemwerkzeuge"]},
	{"Unterhaltungsmedien", menu_parts["Unterhaltungsmedien"]},
	{"Zubehör", menu_parts["Zubehör"]},
}

return xdg_menu
