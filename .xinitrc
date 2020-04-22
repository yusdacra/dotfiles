#!/bin/sh

userresources=$HOME/.Xresources
usermodmap=$HOME/.Xmodmap
sysresources=/etc/X11/xinit/.Xresources
sysmodmap=/etc/X11/xinit/.Xmodmap

# merge in defaults and keymaps

if [ -f $sysresources ]; then
    xrdb -merge $sysresources
fi

if [ -f $sysmodmap ]; then
    xmodmap $sysmodmap
fi

if [ -f "$userresources" ]; then
    xrdb -merge "$userresources"
fi

if [ -f "$usermodmap" ]; then
    xmodmap "$usermodmap"
fi

if [ -f "/tmp/dwm-status.pid" ]; then
	rm "/tmp/dwm-status.pid"
fi

/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1 &
picom --experimental-backends --config $HOME/.config/picom/picom.conf &
sxhkd &
$HOME/scripts/dwm-status.sh &

~/.fehbg
xset led 3
setxkbmap tr
pywal-discord

exec dwm
