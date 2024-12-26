#!/bin/bash
echo -n "Shuffling files, please wait..."

shuf "$scraperdir/metadata/videos.txt" > "$scraperdir/metadata/videos.txt_tmp" && mv "$scraperdir/metadata/videos.txt_tmp" "$scraperdir/metadata/videos.txt"
shuf "$scraperdir/metadata/videos_archived.txt" > "$scraperdir/metadata/videos_archived.txt_tmp" && mv "$scraperdir/metadata/videos_archived.txt_tmp" "$scraperdir/metadata/videos_archived.txt"
shuf "$scraperdir/metadata/channels.txt" > "$scraperdir/metadata/channels.txt_tmp" && mv "$scraperdir/metadata/channels.txt_tmp" "$scraperdir/metadata/channels.txt"
shuf "$scraperdir/metadata/channels_archived.txt" > "$scraperdir/metadata/channels_archived.txt_tmp" && mv "$scraperdir/metadata/channels_archived.txt_tmp" "$scraperdir/metadata/channels_archived.txt"

echo "complete!"
echo ""
