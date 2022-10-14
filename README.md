# SlimeOS-awesome

My dotfiles for the awesome window manager.

![SlimeOS screenshot](/assets/screenshot0.png)

TL;DR: To install on Arch Linux, please run the included `install.sh` script.

## Dependencies

### Required dependencies:
 - The awesome window manager (Use the latest git master branch compiled against `luajit`)
 - `playerctl` - For the media player widget
 - `inotify-tools` - For watching the file system for changes
 - `pacmd` (included with PulseAudio) and `perl` - For showing a volume slider in each apps title bar automatically
 - `lxqt-config` and `lxqt-session` - For session managemant
 - Papirus icon theme (this will become optional later on when I properly clean up the code)

### Optional dependencies (recommend, but not strictly necessary):
 - Nitrogen - For setting the wallpaper
 - Konsole - The default terminal emulator
 - Dolphin - The default file manager
 - Firefox - The default web browser
 - Ant Dracula theme (GTK and Kvantum)

To install all dependencies at once on Arch linux, you can use the following command (assuming you have the `paru` AUR helpler installed):

```bash
paru --needed -S konsole-dracula-git ant-dracula-gtk-theme ant-dracula-kde-theme ant-dracula-kvantum-theme-git awesome-luajit-git playerctl inotify-tools pulseaudio perl papirus-icon-theme nitrogen konsole dolphin firefox lxqt-config lxqt-session
```

## Installing

After installing all dependencies, you can use the following command to install this repo:

```bash
git clone --recursive-submodules https://github.com/SkyyySi/SlimeOS-awesome "$HOME/Dots/awesome"
if [[ -d "${XDG_CONFIG_HOME:-$HOME/.config}/awesome" ]]; then
	mv "${XDG_CONFIG_HOME:-$HOME/.config}/awesome" "${XDG_CONFIG_HOME:-$HOME/.config}/awesome_backup_$(LANG=C date '+%F__%T')"
fi
ln -s "$HOME/Dots/awesome/src" "${XDG_CONFIG_HOME:-$HOME/.config}/awesome"
```

## Contributing

Feel free to open an issue/PR if you want to change something or just ask a question.
Alternatively, contact me on Discord: `!SkyyySi#1850` (or hop on the official awesome wm
server, where I am somewhat active as well: <https://discord.gg/BPat4F87dg>)
