#!/bin/sh -ex

echo "Fixing perms..."

# TODO: use overlay helper script https://github.com/just-containers/s6-overlay/issues/97
for x in /config "/config/Library/Application Support/Plex Media Server/Logs" /transcode /data/*
do
    if [ "$(stat -c '%U' "$x")" != "plex" ]; then
        chown -R plex:plex "$x"
        echo " - $x"
    fi
done

# https://github.com/mandreko/pms-docker/pull/1
exec s6-setuidgid plex /bin/sh -c 'umask 0002'
