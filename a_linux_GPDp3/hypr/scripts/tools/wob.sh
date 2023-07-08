#!/usr/bin/bash

$WOBSOCK=$XDG_RUNTIME_DIR/wob.sock
mkfifo $WOBSOCK
rm -f $WOBSOCK
tail -f $WOBSOCK | wob &> /dev/null
