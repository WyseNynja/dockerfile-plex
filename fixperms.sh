#!/usr/bin/env bash

echo "Fixing perms..."

# TODO: use overlay helper script https://github.com/just-containers/s6-overlay/issues/97
chown plex:plex /config  # NOT recursive which could cause problems, but recursive takes a LONG time with a large library

for x in "/config/Library/Application Support/Plex Media Server/Logs" /dev/dri /dev/dvb /transcode /data/* /var/log/PlexComskip.log /opt/PlexComskip
do
    if [ -e "$x" ] && [ "$(stat -c '%U' "$x")" != "plex" ]; then
        find "$x" ! -user plex -print -exec chown plex:plex {} \;
    fi
done

echo "Permissions fixed."

# https://github.com/mandreko/pms-docker/pull/1
exec s6-setuidgid plex /bin/sh -c 'umask 0002'
