#!/bin/bash
echo -n "$videoid (scrapin' metadata..."
echo $videoid >> "$scraperdir/metadata/videos.txt"
echo $channelid >> "$scraperdir/metadata/channels.txt"
checkiferror=$(yt-dlp --quiet --geo-bypass --flat-playlist --get-duration -q https://www.youtube.com/watch?v=$videoid | sed -e 's/\r/ /g' | sed ':a;N;$!ba;s/\n/ /g')   
if [[ $checkiferror != "" || $? != "0" ]]; then    
   
    checkifdateexists=$(grep -e "$videoid|" "$scraperdir/metadata/youtube_video_dates.csv") #Check if metadata already exists
    if [[ $checkifdateexists == "" ]] ; then
        yt-dlp --quiet --geo-bypass --flat-playlist --skip-download --write-description -q -o "%(upload_date>%Y-%m-%d)s" "https://www.youtube.com/watch?v=$videoid/"
        date=$(ls *.description | cut -d "." -f 1)    
        rm *description
        if [[ "$date" == "" || "$date" == "null" ]]; then
            date="NULL"
        fi   
        echo "$videoid|$date" >> "$scraperdir/metadata/youtube_video_dates.csv"
    fi
    date=$(grep -e "$videoid" "$scraperdir/metadata/youtube_video_dates.csv" | cut -d "|" -f "2-")





    checkiftitleexists=$(grep -e "$videoid|" "$scraperdir/metadata/youtube_video_titles.csv") #Check if metadata already exists
    if [[ $checkiftitleexists == "" ]] ; then
        title=$(yt-dlp --quiet --geo-bypass --flat-playlist --get-title -q https://www.youtube.com/watch?v=$videoid | sed -e 's/\r/ /g' | sed ':a;N;$!ba;s/\n/ /g')            
        if [[ "$title" == ""  || "$title" == "null" ]]; then
            title="NULL"
        fi      
        echo "$videoid|$title" >> "$scraperdir/metadata/youtube_video_titles.csv"
    fi
    title=$(grep -e "$videoid" "$scraperdir/metadata/youtube_video_titles.csv" | cut -d "|" -f "2-")    





    checkifdescriptionexists=$(grep -e "$videoid|" "$scraperdir/metadata/youtube_video_descriptions.csv") #Check if metadata already exists
    if [[ $checkifdescriptionexists == "" ]] ; then
        description=$(yt-dlp --quiet --geo-bypass --flat-playlist --get-description -q https://www.youtube.com/watch?v=$videoid | sed -e 's/\r//g' | sed ':a;N;$!ba;s/\n/ %0A /g')  
        if [[ "$description" == "" || "$description" == "null" ]]; then
            description="NULL"
        fi
        echo "$videoid|$description" >> "$scraperdir/metadata/youtube_video_descriptions.csv"
    fi
    description=$(grep -e "$videoid" "$scraperdir/metadata/youtube_video_descriptions.csv" | cut -d "|" -f "2-" | sed -e 's/ %0A /<br>/g')





    checkifuploaderexists=$(grep -e "$videoid|" "$scraperdir/metadata/youtube_video_uploaders.csv") #Check if metadata already exists
    if [[ $checkifuploaderexists == "" ]] ; then
        yt-dlp --quiet --geo-bypass --flat-playlist --skip-download --write-description -q -o "%(channel_id)s" "https://www.youtube.com/watch?v=$videoid/"
        channelid=$(ls *.description | cut -d "." -f 1)    
        rm *description
        if [[ "$channelid" == "" || "$channelid" == "null" ]]; then
            channelid="NULL"
        fi   
        echo "$videoid|$channelid" >> "$scraperdir/metadata/youtube_video_uploaders.csv"
    fi
    channelid=$(grep -e "$videoid" "$scraperdir/metadata/youtube_video_uploaders.csv" | cut -d "|" -f "2-")





    checkifchannelnameexists=$(grep -e "$channelid|" "$scraperdir/metadata/youtube_channel_names.csv") #Check if metadata already exists
    if [[ $checkifchannelnameexists == "" ]] ; then
        yt-dlp --quiet --geo-bypass --flat-playlist --skip-download --write-description -q -o "%(channel)s" "https://www.youtube.com/watch?v=$videoid/"
        channelname=$(ls *.description | cut -d "." -f 1)    
        rm *description
        if [[ "$channelname" == "" || "$channelname" == "null" ]]; then
            channelname="NULL"
        fi
        echo "$channelid|$channelname" >> "$scraperdir/metadata/youtube_channel_names.csv"
    fi
    channelname=$(grep -e "$channelid" "$scraperdir/metadata/youtube_channel_names.csv" | cut -d "|" -f "2-" | sed -e 's/ %0A /<br>/g')




    if [[ $invidiousactive == "true" ]]; then
        checkifchanneldescriptionexists=$(grep -e "$channelid|" "$scraperdir/metadata/youtube_channel_descriptions.csv") #Check if metadata already exists
        if [[ $checkifchanneldescriptionexists == "" ]] ; then
            channeldescription=$(curl -s "https://$invidious/api/v1/channels/$channelid" | jq -r '.description' | sed -e 's/\r//g' | sed -e ':a;N;$!ba;s/\n/ %0A /g' 2> /dev/null)
            if [[ "$channeldescription" == "" || "$channeldescription" == "null" ]]; then
                channeldescription="NULL"
            fi
            echo "$channelid|$channeldescription" >> "$scraperdir/metadata/youtube_channel_descriptions.csv"
        fi
        channeldescription=$(grep -e "$channelid" "$scraperdir/metadata/youtube_channel_descriptions.csv" | cut -d "|" -f "2-" | sed -e 's/ %0A /<br>/g')
    fi

    echo -n "complete..."
    metadataerror=false

else
    echo -n "something went wrong...skipping for now...)"
    metadataerror=true
fi
