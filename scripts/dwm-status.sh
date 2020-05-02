#!/bin/sh
sep="|"
pid="/tmp/dwm-status.pid"

time="date +'%H:%M'"
volume="amixer -D pulse get Master | awk -F'[][]' -f $HOME/scripts/volume.awk"
mpd_status="mpc status 2>&1 | awk -f $HOME/scripts/mpd-status.awk"

update='xsetroot -name "$(eval $mpd_status) $sep $(eval $volume) $sep $(eval $time)"'

if [ -f $pid ]; then
	eval $update
	exit 1
else
	touch $pid
fi

while true; do
	eval $update
	sleep 1
done
