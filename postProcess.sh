#!/usr/bin/env bash
set -eu

# skip commercials
python2 /opt/PlexComskip/PlexComskip.py "$1" && EXIT_CODE=0 || EXIT_CODE=$?

echo "Extracting subtitles for $1..."
ccextractor -srt -12 "$1" || echo No subtitles
# TODO: "--service all" ?

# if you wanted, you could remux here, but plex supports .srt files

echo "Done with $1. Exit $EXIT_CODE"
exit $EXIT_CODE