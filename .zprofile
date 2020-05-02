#if [ $TERM != "tmux-256color" ]; then
#    wal -Rn
#fi

#export PATH="$HOME/.cargo/bin:$PATH"

#If running from tty1 start sway
if [ "$(tty)" = "/dev/tty1" ]; then
    exec sx sh ~/.xinitrc
fi
