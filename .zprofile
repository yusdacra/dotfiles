wal -Rn

if [ -n "$DESKTOP_SESSION" ];then
    eval $(gnome-keyring-daemon --start)
    export SSH_AUTH_SOCK
fi

#If running from tty1 start sway
if [ "$(tty)" = "/dev/tty1" ]; then
    exec startx
fi
