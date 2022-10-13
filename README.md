# SlimeOS-awesome

## Dependencies

### Required dependencies:
 - The awesome window manager (Use the latest git master branch compiled against `luajit`)
 - `playerctl` - For the media player widget
 - `inotify-tools` - For watching the file system for changes
 - `pacmd` (included with PulseAudio) and `perl` - For showing a volume slider in each apps title bar automatically

### Optional dependencies (recommend):
 - Nitrogen - For setting the wallpaper
 - Konsole - The default terminal emulator
 - Dolphin - The default file manager
 - Firefox - The default web browser
 - Papirus icon theme
 - Ant Dracula theme (GTK and Kvantum)

To install all dependencies at once on Arch linux, you can use the following command (assuming you have the `paru` AUR helpler installed):

```bash
paru --needed -S konsole-dracula-git ant-dracula-gtk-theme ant-dracula-kde-theme ant-dracula-kvantum-theme-git awesome-luajit-git playerctl inotify-tools pulseaudio perl papirus-icon-theme nitrogen konsole dolphin firefox
```
