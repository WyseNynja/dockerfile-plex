#!/bin/sh -ex

echo "Fixing perms..."

for x in /config "/config/Library/Application Support/Plex Media Server/Logs" /transcode /data/*
do
    if [ "$(stat -c '%U' "$x")" != "plex" ]; then
        chown -R plex:plex "$x"
        echo " - $x"
    fi
done
