BEGIN{n=""; p=""; t="";} (NR==1){n=$0;} (NR==2){p=$1; t=$3;} END{if (index(n, "error")){print "Disconnected";} else if (index(n, "volume")){print "Stopped";} else {print p" "n" "t;}}
