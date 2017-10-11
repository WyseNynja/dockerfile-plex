#!/bin/bash

echo "Fixing perms..."

# TODO: use overlay helper script https://github.com/just-containers/s6-overlay/issues/97
for x in /config "/config/Library/Application Support/Plex Media Server/Logs" /dev/dri /dev/dvb /transcode /data/* /var/log/PlexComskip.log /opt/PlexComskip
do
    if [ -e "$x" ] && [ "$(stat -c '%U' "$x")" != "plex" ]; then
        find "$x" ! -user plex -exec chown plex:plex {} \; &
        echo " - $x"
    fi
done
wait

# https://github.com/mandreko/pms-docker/pull/1
exec s6-setuidgid plex /bin/sh -c 'umask 0002'
