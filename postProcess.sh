#!/usr/bin/env bash
[ -z "$SKIP_COMSKIP" ] && SKIP_COMSKIP=0

set -eu

crf=23  # default is 28, but i want better quality than default
preset=slow  # was ultrafast  # doesn't change the quality, just changes the end file size

filename=$1
shift

echo "Processing $filename..."

work_dir=$(mktemp -d -p /transcode)

cd "$work_dir"

trap 'rm -rf "$work_dir"' EXIT

tmp_name="${work_dir}/$(basename "$filename")"

show_name="$(basename "${tmp_name%.*}")"

cp "$filename" "$tmp_name"

if [ "$SKIP_COMSKIP" = "0" ]; then
    # skip commercials
    python2 /opt/PlexComskip/PlexComskip.py "$tmp_name" && COMSKIP_EXIT=0 || COMSKIP_EXIT=$?
else
    echo "Skipping running PlexComskip.py..."
    COMSKIP_EXIT=-1
fi

# we used to extract subtitles, since plex can't read them out of .ts files
# but plex can read them out of mp4
dest_filename="${show_name}.mp4"
tmp_mp4="${work_dir}/${dest_filename}"
# highest quality vbr audio is smaller and just as a good as the 326kbit ac3 from the capture gard
# copy the subtitiles
# h265 for the video. 5GB.ts to 678.3MB.ultrafast.mp4
ffmpeg \
    -i "$tmp_name" \
    -c:a aac -strict -2 -vbr 5 \
    -c:s copy \
    -c:v libx265 -crf "$crf" -preset "$preset" \
    "$tmp_mp4"

echo "ffmpeg completed succesfully. Moving file..."
# put the transcoded file next to the original
# dest_dir=$(dirname "$filename")
# OR put the transcoded file in the downloads directory
# TODO: what if I tell plex to record a movie?
dest_dir=/downloads/shows
mv "$tmp_mp4" "${dest_dir}/${dest_filename}"

# now that a smaller file is in place, delete the original
# TODO: option to move this to a temporary holding directory just in case comskip cut too much
rm "$filename"

echo "Done with ${dest_dir}/${dest_filename}. Comskip exit $COMSKIP_EXIT"
exit $COMSKIP_EXIT
