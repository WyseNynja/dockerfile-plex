#!/bin/bash

set -e

# skip commercials
python3 /opt/PlexComskip/PlexComskip.py "$1"

echo "Extracting subtitles for $1..."
ccextractor -srt -12 "$1"
# TODO: "--service all" ?

# if you wanted, you could remux here, but plex supports .srt files

echo "Done with $1"
