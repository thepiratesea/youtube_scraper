#!/bin/bash
clear
scraperdir=$PWD
echo ""
echo "Which metadata do ye want t' merge?"
echo ""
echo "1. Channel Name"
echo "2. Channel Description"
echo "3. Video Title"
echo "4. Video Date"
echo "5. Video Description"
echo "6. Video Uploader"
echo ""
echo "=========Type Here==========="
read metadataselection
echo "============================="

if [[ $metadataselection == "1" ]]; then
    destfile="$scraperdir/metadata/youtube_channel_names.csv"
elif [[ $metadataselection == "2" ]]; then
    destfile="$scraperdir/metadata/youtube_channel_descriptions.csv"
elif [[ $metadataselection == "3" ]]; then
    destfile="$scraperdir/metadata/youtube_video_titles.csv"
elif [[ $metadataselection == "4" ]]; then
    destfile="$scraperdir/metadata/youtube_video_dates.csv"
elif [[ $metadataselection == "5" ]]; then
    destfile="$scraperdir/metadata/youtube_video_descriptions.csv"
elif [[ $metadataselection == "6" ]]; then
    destfile="$scraperdir/metadata/youtube_video_uploaders.csv"
else
    echo "Invalid Selection"
    break
fi

echo ""
echo "Enter the path to yer source file"
echo ""
echo "=========Type Here==========="
read srcfile
echo "============================="

if [[ -f $srcfile ]]; then
    echo ""
    echo "Which line ye want t' start on?"
    echo ""
    echo "=========Type Here==========="
    read linenum
    echo "============================="
    if [[ $linenum == "" ]]; then
        linenum=1
    fi
    while :
    do
        id=$(sed "${linenum}q;d"  "$srcfile" | cut -d "|" -f "1" | awk '"{ print $1 }"') #Grab an id from the source file
        data=$(sed "${linenum}q;d"  "$srcfile" | cut -d "|" -f "2" | awk '"{ print $1 }"') #Grab data from the source file
        checkifexists=$(grep -e "$id" "$destfile") #Check if metadata already exists in destination file
        if [[ $checkifexists == "" ]]; then
            echo "$id|$data" >> $destfile
            echo "$linenum - $id merged to $destfile"
        else
             echo "$linenum - $id is a duplicate...skipping"   
        fi
        if [[ $id == "" ]];  then
            echo "End of $srcfile"
            break
        else
            linenum=$(($linenum + 1))
        fi
    done
else
    echo "$srcfile don't exist!"
fi
sleep 3
