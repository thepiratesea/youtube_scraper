#!/bin/bash
checkifexists=$(grep -e "$videoid" "$scraperdir/metadata/youtubeid.csv") #Check if video has already been downloaded
checkifexistsoldlist=$(grep -e "$videoid" "$scraperdir/metadata/videos_archived.txt") #Check if video has already been downloaded
if [[ $checkifexists == "" && $checkifexistsoldlist == "" ]]; then
    echo -n "downloadin' video..."
    yt-dlp --ignore-errors -f "bestvideo[height<=360][ext=mp4]+bestaudio[ext=m4a]" --geo-bypass -q -o "$scraperdir/videos/%(id)s.mp4" "https://www.youtube.com/watch?v=$videoid"
    if [[ $? == "0" ]]; then
        echo -n "complete...hashin' file..."
        {
        eyeD3 --remove-all "$scraperdir/videos/$videoid.mp4"
        exiftool -overwrite_original -all= "$scraperdir/videos/$videoid.mp4"
        } &> /dev/null
        sha256sum=$(sha256sum "$scraperdir/videos/$videoid.mp4" | cut -d " " -f "1")
        duration=$(ffprobe -show_entries format=duration -v quiet -of csv="p=0" "$scraperdir/videos/$videoid.mp4" | cut -d "." -f 1)
        size=`du -B 1 "$scraperdir/videos/$videoid.mp4" | cut -f1`
        audio_bitrate=$(ffprobe -v quiet -select_streams a:0 -show_entries stream=bit_rate -of default=noprint_wrappers=1 "$scraperdir/videos/$videoid.mp4" | cut -d "=" -f 2)
        video_bitrate=$(ffprobe -v quiet -select_streams v:0 -show_entries stream=bit_rate -of default=noprint_wrappers=1 "$scraperdir/videos/$videoid.mp4" | cut -d "=" -f 2)
        resolution=$(ffprobe -v error -select_streams v:0 -show_entries stream=width,height -of csv=s=x:p=0 "$scraperdir/videos/$videoid.mp4")                
        newvalue=$title
        source "$scraperdir/encode_new_value.sh"
        encodedtitle=$newvalue
        echo "$sha256sum:$encodedtitle-$videoid.mp4" >> $scraperdir/metadata/name.csv
        echo "$sha256sum:.mp4" >> $scraperdir/metadata/extension.csv
        echo "$sha256sum:$videoid" >> $scraperdir/metadata/youtubeid.csv
        echo $videoid >> "$scraperdir/metadata/videos_archived.txt"
        echo "$sha256sum:$date" >> $scraperdir/metadata/date.csv
        echo "$sha256sum:$duration" >> $scraperdir/metadata/duration.csv
        echo "$sha256sum:$size" >> $scraperdir/metadata/size.csv
        echo "$sha256sum:$audio_bitrate" >> $scraperdir/metadata/audio_bitrate.csv
        echo "$sha256sum:$video_bitrate" >> $scraperdir/metadata/video_bitrate.csv
        echo "$sha256sum:$resolution" >> $scraperdir/metadata/resolution.csv
        mv "$scraperdir/videos/$videoid.mp4" "$scraperdir/videos/$sha256sum"
        touch -t 199912312359.59 "$scraperdir/videos/$sha256sum"
        echo "complete! Archived as $sha256sum ($size bytes and $duration second duration)."
        echo ""
        downloaderror=false
    else
        echo "something went wrong...skipping.)"
        downloaderror=true
    fi
else
    echo "already downloaded...skipping.)"
    echo ""
fi
