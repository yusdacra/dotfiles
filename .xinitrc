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

#/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1 &

~/.fehbg
xset led on
setxkbmap tr
cat /proc/uptime >> ~/.boottime

exec runsvdir -P ~/.config/service.x 'log: ...........................................................................................................................................................................................................................................................................................................................................................................................................'
