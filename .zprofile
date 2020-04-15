if [ $TERM != "tmux-256color" ]; then
    wal -Rn
fi

#If running from tty1 start sway
if [ "$(tty)" = "/dev/tty1" ]; then
    exec sway
fi
