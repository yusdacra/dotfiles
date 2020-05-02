#!/bin/sh

install -d /etc/sv/runsvdir-yusuf
install -m755 runsvdir-yusuf/run /etc/sv/runsvdir-yusuf/run
install -m755 runsvdir-yusuf/finish /etc/sv/runsvdir-yusuf/finish
ln -sf /run/runit/supervise.runsvdir-yusuf /etc/sv/runsvdir-yusuf/supervise
