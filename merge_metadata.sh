#!/bin/bash
echo ""
echo "Which metadata do ye want t' merge?"
echo ""
echo "1. Channel Name (youtube_channel_names.csv)"
echo "2. Channel Description (youtube_channel_descriptions.csv)"
echo "3. Video Title (youtube_video_titles.csv)"
echo "4. Video Date (youtube_video_dates.csv)"
echo "5. Video Description (youtube_video_descriptions.csv)"
echo "6. Video Uploader (youtube_video_uploaders.csv)"
echo "7. Archived Videos (youtubeid.csv)"
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
elif [[ $metadataselection == "7" ]]; then
    destfile="$scraperdir/metadata/youtubeid.csv"
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





    if [[ $metadataselection == "1" || $metadataselection == "2" || $metadataselection == "3" || $metadataselection == "4" || $metadataselection == "5" || $metadataselection == "6" ]]; then
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
                 echo "$linenum - $id is a duplicate...skipping" >> $scraperdir/log.txt
            fi
            if [[ $id == "" ]];  then
                echo "End of $srcfile"
                break
            else
                linenum=$(($linenum + 1))
            fi
        done
    fi





    if [[ $metadataselection == "7" ]]; then
        while :
        do
            hash=$(sed "${linenum}q;d"  "$srcfile" | cut -d ":" -f "1" | awk '"{ print $1 }"') #Grab a hash from the source file
            data=$(sed "${linenum}q;d"  "$srcfile" | cut -d ":" -f "2" | awk '"{ print $1 }"') #Grab data from the source file
            checkifexists=$(grep -e "$hash" "$destfile") #Check if metadata already exists in destination file
            if [[ $checkifexists == "" ]]; then
                echo "$hash:$data" >> $destfile
                echo "$linenum - $hash merged to $destfile"
            else
                 echo "$linenum - $hash is a duplicate...skipping"   
                 echo "$linenum - $hash is a duplicate...skipping" >> $scraperdir/log.txt
            fi
            if [[ $hash == "" ]];  then
                echo "End of $srcfile"
                break
            else
                linenum=$(($linenum + 1))
            fi
        done
    fi





else
    echo "$srcfile don't exist!"
fi
sleep 3
