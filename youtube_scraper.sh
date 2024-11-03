#!/bin/bash
clear
scraperdir=$PWD
source font.sh
mkdir $scraperdir/metadata 2>/dev/null
mkdir $scraperdir/search 2>/dev/null
mkdir $scraperdir/videos 2>/dev/null
mkdir $scraperdir/pages 2>/dev/null
mkdir $scraperdir/channels 2>/dev/null
mkdir $scraperdir/playlists 2>/dev/null

source "$scraperdir/select_invidious_instance.sh"
echo ""
echo "What ye want t' do?"
echo ""
echo "1) Search"
echo "2) Scrape"
echo "3) Download"
echo "4) Comment"
echo "5) Favorites (WIP)"
echo "6) Merge Metadata"
echo ""
echo "=========Type Here==========="
read mainoption
echo "============================="
###SEARCH###
if [[ $mainoption == "1" ]]; then
    echo ""
    echo "Search fer a term."
    echo ""
    echo "=========Type Here==========="
    read query
    echo "============================="
    echo ""
    grep -i "$query" "$scraperdir/metadata/youtube_video_dates.csv" | cut -d "|" -f "1" > search.txt
    grep -i "$query" "$scraperdir/metadata/youtube_video_titles.csv" | cut -d "|" -f "1" >> search.txt
    grep -i "$query" "$scraperdir/metadata/youtube_video_descriptions.csv" | cut -d "|" -f "1" >> search.txt
    sort -u -r search.txt > search.txt_tmp && mv search.txt_tmp search.txt
    echo "" > search.html_tmp
    echo "Searching for "$query"....please wait"
    echo ""
    linenum=1
    while :
    do
        videoid=$(awk 'NR=='$linenum'' "search.txt")
        date=$(grep -e "$videoid" "$scraperdir/metadata/youtube_video_dates.csv" | cut -d "|" -f "2-")
        title=$(grep -e "$videoid" "$scraperdir/metadata/youtube_video_titles.csv" | cut -d "|" -f "2-")
        description=$(grep -e "$videoid" "$scraperdir/metadata/youtube_video_descriptions.csv" | cut -d "|" -f "2-")
        if [[ $videoid == "" ]]; then
            count=$(wc -l search.html_tmp | cut -d " " -f 1)
            sort -u -r search.html_tmp > search.html_tmp2 && mv search.html_tmp2 search.html_tmp
            echo "<title>The Pirate Sea | search results for: $query</title>" > search.html                
            echo "<style>" >> search.html
            echo 'a {color: FFFFFF;}' >> search.html                
            echo 'body {background-color: 303030; color: FFFFFF; width: 95%;}' >> search.html
            echo "</style>" >> search.html
            echo '<h1>'$count' Search results for "'$query'"</h1>' >> search.html
            cat search.html_tmp >> search.html
            sha256sum=$(echo "$query" | sha256sum | cut -d " " -f "1")
            mv search.html $scraperdir/search/$sha256sum.html
            xdg-open $scraperdir/search/$sha256sum.html
            rm search.txt
            rm search.html_tmp
            source "$scraperdir/youtube_scraper.sh"
        else
            echo "$title"
            echo -n "$date | <a href="https://www.youtube.com/watch?v=$videoid" target="_blank">[Y]</a>" >> search.html_tmp
            if [[ -f "$scraperdir/pages/$videoid.html" ]]; then
                echo -n " <a href="$scraperdir/pages/$videoid.html" target="_blank">[L]</a>" >> search.html_tmp
            fi
            echo " <b>$title</b> <br>" >> search.html_tmp            
            linenum=$(($linenum + 1))
        fi
    done
fi
###SCRAPE###
if [[ $mainoption == "2" ]]; then
    echo ""
    echo "What ye want t' scrape?"
    echo ""
    echo "1) Channel IDs only"
    echo "2) Video IDs only"
    echo "3) Video Metadata only"
    echo "4) Channel Info only"
    echo "5) Targeted Channel Scraper"
    echo "6) Targeted Playlist Scraper"
    echo "7) SCRAPE IT ALL!!!"
    echo ""
    echo "=========Type Here==========="
    read scrapeoption
    echo "============================="
    echo ""
    if [[ $scrapeoption == "1" ]]; then ##Channel IDs only
        videolistcount=$(wc -l videos.txt | cut -d " " -f 1)
        if [[ $videolistcount -gt "100" ]]; then
            sort -u videos.txt > videos.txt_tmp && mv videos.txt_tmp videos.txt
            shuf videos.txt > videos.txt_tmp && mv videos.txt_tmp videos.txt
            videolinenum=1
            while :
            do
                echo "Scrapin' channel IDs...please wait"
                echo ""
                linenum=1
                videoid=$(awk 'NR=='$videolinenum'' "videos.txt")
                curl -s https://$invidious/api/v1/videos/$videoid?fields=recommendedVideos | jq -r '.recommendedVideos[].authorId' 2> /dev/null >> channel_ids.txt
                while :
                do
                    channelid=$(awk 'NR=='$linenum'' "channel_ids.txt")
                    if [[ $channelid == "" ]]; then
                        break
                    else
                        echo "$channelid" >> channels.txt
                        linenum=$(($linenum + 1))
                    fi
                done
                sort -u channels.txt > channels.txt_tmp && mv channels.txt_tmp channels.txt
                shuf channels.txt > channels.txt_tmp && mv channels.txt_tmp channels.txt
                #rm channel_ids.txt
                videocount=$(wc -l "videos.txt" | cut -d " " -f 1)
                channelcount=$(wc -l "channels.txt" | cut -d " " -f 1)
                metadatacount=$(wc -l "$scraperdir/metadata/youtube_video_dates.csv" | cut -d " " -f 1)
                echo "--- Statistics ---"
                echo ""
                echo "Channel IDs - $channelcount"
                echo "Video IDs - $videocount"
                echo "Video Metadata - $metadatacount"
                echo ""
                echo "Would ye like t' continue scrapin' channel IDs? (y/N)"
                echo ""
                echo "=========Type Here==========="
                read -t 3 continue
                echo "============================="
                echo ""
                if [[ $continue == "y" || $continue == "" ]]; then
                    videolinenum=$(($videolinenum + 1))
                else
                    break
                fi
            done
        else
            echo "Ye need at least 100 videos in yer videos.txt t' scrape channel IDs!"
            source "$scraperdir/youtube_scraper.sh"
        fi
    elif [[ $scrapeoption == "2" ]]; then ##Video IDs only
        channellistcount=$(wc -l channels.txt | cut -d " " -f 1)
        if [[ $channellistcount -gt "100" ]]; then
            echo "How many video IDs would ye like t' grab from each playlist?"
            echo ""
            echo "=========Type Here==========="
            read -t 30 specifynum
            echo "============================="
            echo ""
            while :
            do
                sort -u channels.txt > channels.txt_tmp && mv channels.txt_tmp channels.txt
                shuf channels.txt > channels.txt_tmp && mv channels.txt_tmp channels.txt
                channelid=$(awk 'NR=='1'' "channels.txt")
                if [[ $specifynum == "" ]]; then
                    num=$((1 + $RANDOM % 10000))
                else
                    num=$specifynum
                fi
                ###GET CHANNEL INFO###
                checkifexists=$(grep -e "$channelid" "$scraperdir/metadata/youtube_channel_names.csv") #Check if metadata already exists
                if [[ $checkifexists == "" ]]; then
                    channelname=$(curl -s https://$invidious/api/v1/channels/$channelid | jq -r '.author' 2> /dev/null)
                    channeldescription=$(curl -s https://$invidious/api/v1/channels/$channelid | jq -r '.description' | sed -e 's/\r//g' | sed -e ':a;N;$!ba;s/\n/ %0A /g' 2> /dev/null)
                    if [[ $channelname == "" || $channelname == "null" ]]; then
                        channelname=NULL                
                    fi                            
                    if [[ $channeldescription == "" || $channeldescription == "null" ]]; then
                        channeldescription=NULL
                    fi        
                    echo "$channelid|$channelname" >> "$scraperdir/metadata/youtube_channel_names.csv"
                    echo "$channelid|$channeldescription" >> "$scraperdir/metadata/youtube_channel_descriptions.csv"
                else
                    channelname=$(grep -e "$channelid" "$scraperdir/metadata/youtube_channel_names.csv" | cut -d "|" -f "2-")
                    channeldescription=$(grep -e "$channelid" "$scraperdir/metadata/youtube_channel_descriptions.csv" | cut -d "|" -f "2-")
                fi
                ###GET VIDEO IDS###
                echo -n "Scrapin' $num videos from $channelname ($channelid)..."
                origvidcount=$(wc -l "$scraperdir/videos.txt" | cut -d " " -f 1)
                yt-dlp --geo-bypass --playlist-end $num --flat-playlist --get-id "https://www.youtube.com/channel/$channelid/videos" >> "$scraperdir/videos.txt"
                newvidcount=$(wc -l "$scraperdir/videos.txt" | cut -d " " -f 1)
                scrapecount=$(($newvidcount - $origvidcount))
                echo "...successfully scraped $scrapecount video IDs!"
                echo ""
                ####GET RECOMMENDED###
                curl -s https://$invidious/api/v1/videos/$videoid?fields=recommendedVideos | jq -r '.recommendedVideos[].videoId' 2> /dev/null >> videos.txt
                videocount=$(wc -l "videos.txt" | cut -d " " -f 1)
                channelcount=$(wc -l "channels.txt" | cut -d " " -f 1)
                metadatacount=$(wc -l "$scraperdir/metadata/youtube_video_dates.csv" | cut -d " " -f 1)
                #rm "$scraperdir/video_ids.txt"
                echo "--- Statistics ---"
                echo ""
                echo "Channel IDs - $channelcount"
                echo "Video IDs - $videocount"
                echo "Video Metadata - $metadatacount"
                echo ""
                echo "Would ye like t' continue scrapin' video IDs? (y/N)"
                echo ""
                echo "=========Type Here==========="
                read -t 3 continue
                echo "============================="
                echo ""
                if [[ $continue == "y" || $continue == "" ]]; then
                    :
                else
                    break
                fi
            done
        else
            echo "Ye need at least 100 channels in yer channels.txt t' scrape video IDs!"
            source "$scraperdir/youtube_scraper.sh"
        fi
    elif [[ $scrapeoption == "3" ]]; then ##Video Metadata Only
        videolistcount=$(wc -l videos.txt | cut -d " " -f 1)
        if [[ $videolistcount -gt "100" ]]; then
            sort -u videos.txt > videos.txt_tmp && mv videos.txt_tmp videos.txt
            shuf videos.txt > videos.txt_tmp && mv videos.txt_tmp videos.txt
            linenum=1
            while :
            do
                videoid=$(awk 'NR=='$linenum'' "videos.txt")
                if [[ $videoid != "" ]]; then
                    ###DOWNLOAD VIDEO METADATA###
                    source $scraperdir/youtube_scraper_download_video_metadata.sh
                    videocount=$(wc -l "videos.txt" | cut -d " " -f 1)
                    channelcount=$(wc -l "channels.txt" | cut -d " " -f 1)
                    metadatacount=$(wc -l "$scraperdir/metadata/youtube_video_dates.csv" | cut -d " " -f 1)
                    echo "--- Statistics ---"
                    echo ""
                    echo "Channel IDs - $channelcount"
                    echo "Video IDs - $videocount"
                    echo "Video Metadata - $metadatacount"
                    echo ""
                    echo "Would ye like t' continue scrapin' video metadata? (y/N)"
                    echo ""
                    echo "=========Type Here==========="
                    read -t 3 continue
                    echo "============================="
                    echo ""
                    if [[ $continue == "y" || $continue == "" ]]; then
                        linenum=$(($linenum + 1))
                    else
                        break
                    fi
                else
                    break
                fi
            done
        else
            echo "Ye need at least 100 videos in yer videos.txt t' scrape video IDs!"
            source "$scraperdir/youtube_scraper.sh"
        fi
    elif [[ $scrapeoption == "4" ]]; then ##Channel Info Only
        sort -u $scraperdir/channels.txt > $scraperdir/channels.txt_tmp && mv $scraperdir/channels.txt_tmp $scraperdir/channels.txt
        #shuf channels.txt > channels.txt_tmp && mv channels.txt_tmp channels.txt
        touch "$scraperdir/metadata/youtube_channel_names.csv"
        touch "$scraperdir/metadata/youtube_channel_descriptions.csv"
        channelnum=1
        while :
        do
            channelid=$(awk 'NR=='$channelnum'' "$scraperdir/channels.txt")
            if [[ $channelid == "" ]]; then
                break
            fi
            echo -n "Scraping info for channel $channelid..."
            ###GET CHANNEL INFO###
            checkifexists=$(grep -e "$channelid" "$scraperdir/metadata/youtube_channel_names.csv") #Check if metadata already exists
            if [[ $checkifexists == "" ]]; then        
                channelname=$(curl -s https://$invidious/api/v1/channels/$channelid | jq -r '.author' 2> /dev/null)
                channeldescription=$(curl -s https://$invidious/api/v1/channels/$channelid | jq -r '.description' | sed -e 's/\r//g' | sed -e ':a;N;$!ba;s/\n/ %0A /g' 2> /dev/null)    
                if [[ $channeldescription == "" || $channeldescription == "null" ]]; then
                    channeldescription=NULL
                fi   
                if [[ $channelname == "" || $channelname == "null" ]]; then
                    channelname=NULL
                fi           
                echo "$channelid|$channelname" >> "$scraperdir/metadata/youtube_channel_names.csv"
                echo "$channelid|$channeldescription" >> "$scraperdir/metadata/youtube_channel_descriptions.csv"
                echo "...complete!"
            else
                channelname=$(grep -e "$channelid" "$scraperdir/metadata/youtube_channel_names.csv" | cut -d "|" -f "2-")
                channeldescription=$(grep -e "$channelid" "$scraperdir/metadata/youtube_channel_descriptions.csv" | cut -d "|" -f "2-")
                echo "...channel info already exists. Skipping."
            fi
            echo ""
            echo "Would ye like t' continue scrapin' channel info? (y/N)"
            echo ""
            echo "=========Type Here==========="
            read -t .01 continue
            echo "============================="
            echo ""
            if [[ $continue == "y" || $continue == "" ]]; then
                channelnum=$(($channelnum + 1))
            else
                break
            fi
        done
    elif [[ $scrapeoption == "5" ]]; then ##TARGETED CHANNEL SCRAPER
        echo "What channel do ye want t' scrape?"
        echo ""
        echo "=========Type Here==========="
        read channelid
        echo "============================="
        echo ""
        echo "How many videos do ye want t' scrape from $channelid?"
        echo ""
        echo "=========Type Here==========="
        read num
        echo "============================="
        echo ""
        echo "Do ye want t' download $num videos from $channelid? (y/N)"
        echo "Note: This could take a very long time, since every video will be downloaded to your hard drive."
        echo ""
        echo "=========Type Here==========="
        read downloadvids
        echo "============================="
        echo ""
        if [[ $num == "" ]]; then
            num=10000000
        fi
        checkiferror=$(curl -s https://$invidious/api/v1/channels/$channelid | jq -r '.error' 2> /dev/null)
        if [[ $checkiferror == "null" ]]; then
            ###GET CHANNEL INFO###
            checkifexists=$(grep -e "$channelid" "$scraperdir/metadata/youtube_channel_names.csv")
            if [[ $checkifexists = "" ]]; then
                channelname=$(curl -s https://$invidious/api/v1/channels/$channelid | jq -r '.author' 2> /dev/null)
                channeldescription=$(curl -s https://$invidious/api/v1/channels/$channelid | jq -r '.description' | sed -e 's/\r//g' | sed -e ':a;N;$!ba;s/\n/ %0A /g' 2> /dev/null)
                if [[ $channelname == "" || $channelname == "null" ]]; then
                    channelname=NULL                
                fi                            
                if [[ $channeldescription == "" || $channeldescription == "null" ]]; then
                    channeldescription=NULL
                fi        
                echo "$channelid|$channelname" >> "$scraperdir/metadata/youtube_channel_names.csv"
                echo "$channelid|$channeldescription" >> "$scraperdir/metadata/youtube_channel_descriptions.csv"
                echo "$channelid" >> "$scraperdir/channels.txt"
            else
                channelname=$(grep -e "$channelid" "$scraperdir/metadata/youtube_channel_names.csv" | cut -d "|" -f "2-")
                channeldescription=$(grep -e "$channelid" "$scraperdir/metadata/youtube_channel_descriptions.csv" | cut -d "|" -f "2-")
            fi
            ###GET VIDEO IDS###
            echo -n "Scrapin' $num videos from $channelname ($channelid)..."
            origvidcount=$(wc -l "$scraperdir/videos.txt" | cut -d " " -f 1)
            yt-dlp --geo-bypass --playlist-end $num --flat-playlist --get-id "https://www.youtube.com/channel/$channelid/videos" > "$scraperdir/video_ids.txt"
            cat "$scraperdir/video_ids.txt" >> "$scraperdir/videos.txt"
            newvidcount=$(wc -l "$scraperdir/videos.txt" | cut -d " " -f 1)
            scrapecount=$(($newvidcount - $origvidcount))
            echo "...successfully scraped $scrapecount video IDs!"
            echo ""
            videonum=1
            while :
            do
                videoid=$(awk 'NR=='$videonum'' "$scraperdir/video_ids.txt")
                if [[ $videoid != "" ]]; then
                    ###DOWNLOAD VIDEO METADATA###
                    source $scraperdir/youtube_scraper_download_video_metadata.sh
                    ###DOWNLOAD VIDEO###
                    if [[ $downloadvids == "y" || $downloadvids == "Y" ]]; then
                        source $scraperdir/youtube_scraper_download_video.sh
                        ###GENERATE VIDEO PAGE###
                        if [[ -f "$scraperdir/pages/$videoid.html" ]]; then
                            :
                        else
                            echo "<title>The Pirate Sea | $title </title>" > "$scraperdir/pages/$videoid.html"                
                            echo "<style>" >> "$scraperdir/pages/$videoid.html"
                            echo 'a {color: FFFFFF;}' >> "$scraperdir/pages/$videoid.html"                
                            echo 'body {background-color: 303030; color: FFFFFF; width: 95%;}' >> "$scraperdir/pages/$videoid.html"
                            echo "</style>" >> "$scraperdir/pages/$videoid.html"
                            echo '<h1>'$title'</h1>' >> "$scraperdir/pages/$videoid.html"
                            echo '<h3>'$videoid'</h3>' >> "$scraperdir/pages/$videoid.html"
                            echo '<p><video controls><source src="'$scraperdir'/videos/'$sha256sum'" type="video/mp4"></video></p>' >> "$scraperdir/pages/$videoid.html"
                            echo "<p><b>$channelname ($channelid)</b></p>" >> "$scraperdir/pages/$videoid.html"
                            echo "<p><b><i>$date</i></b></p>" >> "$scraperdir/pages/$videoid.html"
                            echo "<p>$description</p>" >> "$scraperdir/pages/$videoid.html"
                        fi
                    fi
                    ###GENERATE CHANNEL LIST PAGE###
                    echo -n "$date | <a href="https://www.youtube.com/watch?v=$videoid" target="_blank">[Y]</a>" >> channel.html_tmp
                    if [[ -f "$scraperdir/pages/$videoid.html" ]]; then
                        echo -n " <a href="$scraperdir/pages/$videoid.html" target="_blank">[L]</a>" >> channel.html_tmp
                    fi
                    echo " <b>$title</b> <br>" >> channel.html_tmp    
                    videonum=$(($videonum + 1))
                else
                    count=$(wc -l channel.html_tmp | cut -d " " -f 1)
                    channeldescription=$(grep -e "$channelid" "$scraperdir/metadata/youtube_channel_descriptions.csv" | cut -d "|" -f "2-" | sed -e 's/ %0A /<br>/g')
                    sort -u -r channel.html_tmp > channel.html_tmp2 && mv channel.html_tmp2 channel.html_tmp
                    echo "<title>The Pirate Sea | $channelname ($channelid) </title>" > channel.html                
                    echo "<style>" >> channel.html
                    echo 'a {color: FFFFFF;}' >> channel.html                
                    echo 'body {background-color: 303030; color: FFFFFF; width: 95%;}' >> channel.html
                    echo "</style>" >> channel.html
                    echo '<h1>'$channelname' ('$channelid')</h1>' >> channel.html
                    if [[ $channeldescription == "NULL" ]]; then
                        :
                    else
                        echo "<p><b>$channeldescription</b></p>" >> channel.html
                    fi
                    echo "<h3>$count videos</h3>" >> channel.html
                    cat channel.html_tmp >> channel.html
                    mv channel.html $scraperdir/channels/$channelid.html
                    xdg-open $scraperdir/channels/$channelid.html
                    #rm "$scraperdir/video_ids.txt"
                    rm channel.html_tmp
                    break                
                fi
            done     
        else
            echo "That channel don't exist!"
        fi
    elif [[ $scrapeoption == "6" ]]; then ##TARGETED PLAYLIST SCRAPER
        echo "What playlist do ye want t' scrape?"
        echo ""
        echo "=========Type Here==========="
        read playlistid
        echo "============================="
        echo ""
        echo "How many videos do ye want t' scrape from $playlistid?"
        echo ""
        echo "=========Type Here==========="
        read num
        echo "============================="
        echo ""
        echo "Do ye want t' download $num videos from $playlistid? (y/N)"
        echo "Note: This could take a very long time, since every video will be downloaded to your hard drive."
        echo ""
        echo "=========Type Here==========="
        read downloadvids
        echo "============================="
        echo ""
        if [[ $num == "" ]]; then
            num=10000000
        fi
        playlisttitle=$(curl -s https://$invidious/api/v1/playlists/$playlistid | jq -r '.title' 2> /dev/null)    
        playlistchannelname=$(curl -s https://$invidious/api/v1/playlists/$playlistid | jq -r '.author' 2> /dev/null)    
        playlistchannelid=$(curl -s https://$invidious/api/v1/playlists/$playlistid | jq -r '.authorId' 2> /dev/null)    
        playlistdescription=$(curl -s https://$invidious/api/v1/playlists/$playlistid | jq -r '.description' 2> /dev/null)  
        echo $playlistchannelid >> $scraperdir/channels.txt  
        ###GET VIDEO IDS###
        echo -n "Scrapin' $num videos from $playlistid..."
        origvidcount=$(wc -l "$scraperdir/videos.txt" | cut -d " " -f 1)
        yt-dlp --geo-bypass --playlist-end $num --flat-playlist --get-id "https://www.youtube.com/playlist?list=$playlistid" > "$scraperdir/video_ids.txt"
        cat "$scraperdir/video_ids.txt" >> "$scraperdir/videos.txt"
        newvidcount=$(wc -l "$scraperdir/videos.txt" | cut -d " " -f 1)
        scrapecount=$(($newvidcount - $origvidcount))
        echo "...successfully scraped $scrapecount video IDs!"
        echo ""
        videonum=1
        while :
        do
            videoid=$(awk 'NR=='$videonum'' "$scraperdir/video_ids.txt")
            if [[ $videoid != "" ]]; then
                ###DOWNLOAD VIDEO METADATA###
                source $scraperdir/youtube_scraper_download_video_metadata.sh
                ###DOWNLOAD VIDEO###
                if [[ $downloadvids == "y" || $downloadvids == "Y" ]]; then
                    source $scraperdir/youtube_scraper_download_video.sh
                fi
                ###GENERATE VIDEO PAGE###
                if [[ -f "$scraperdir/pages/$videoid.html" ]]; then
                    :
                else
                    echo "<title>The Pirate Sea | $title </title>" > "$scraperdir/pages/$videoid.html"                
                    echo "<style>" >> "$scraperdir/pages/$videoid.html"
                    echo 'a {color: FFFFFF;}' >> "$scraperdir/pages/$videoid.html"                
                    echo 'body {background-color: 303030; color: FFFFFF; width: 95%;}' >> "$scraperdir/pages/$videoid.html"
                    echo "</style>" >> "$scraperdir/pages/$videoid.html"
                    echo '<h1>'$title'</h1>' >> "$scraperdir/pages/$videoid.html"
                    echo '<h3>'$videoid'</h3>' >> "$scraperdir/pages/$videoid.html"
                    echo '<p><video controls><source src="'$scraperdir'/videos/'$sha256sum'" type="video/mp4"></video></p>' >> "$scraperdir/pages/$videoid.html"
                    echo "<p><b>$channelname ($channelid)</b></p>" >> "$scraperdir/pages/$videoid.html"
                    echo "<p><b><i>$date</i></b></p>" >> "$scraperdir/pages/$videoid.html"
                    echo "<p>$description</p>" >> "$scraperdir/pages/$videoid.html"
                fi
                ###GENERATE PLAYLIST PAGE###
                echo -n "$date | <a href="https://www.youtube.com/watch?v=$videoid" target="_blank">[Y]</a>" >> playlist.html_tmp
                if [[ -f "$scraperdir/pages/$videoid.html" ]]; then
                    echo -n " <a href="$scraperdir/pages/$videoid.html" target="_blank">[L]</a>" >> playlist.html_tmp
                fi
                echo " <b>$title</b> <br>" >> playlist.html_tmp  
                videonum=$(($videonum + 1))
            else
                count=$(wc -l playlist.html_tmp | cut -d " " -f 1)
                sort -u -r playlist.html_tmp > playlist.html_tmp2 && mv playlist.html_tmp2 playlist.html_tmp
                echo "<title>The Pirate Sea | $playlistid </title>" > playlist.html                
                echo "<style>" >> playlist.html
                echo 'a {color: FFFFFF;}' >> playlist.html                
                echo 'body {background-color: 303030; color: FFFFFF; width: 95%;}' >> playlist.html
                echo "</style>" >> playlist.html
                echo '<h1>'$playlisttitle' ('$playlistid')</h1>' >> playlist.html
                echo "<p><b>$playlistchannelname</b></p>" >> playlist.html
                echo "<p><b>$playlistdescription</b></p>" >> playlist.html
                echo "<h3>$count videos</h3>" >> playlist.html
                cat playlist.html_tmp >> playlist.html
                mv playlist.html $scraperdir/playlists/$playlistid.html
                xdg-open $scraperdir/playlists/$playlistid.html
                #rm "$scraperdir/video_ids.txt"
                rm playlist.html_tmp
                break
            fi
    done
    elif [[ $scrapeoption == "7" ]]; then ##SCRAPE IT ALL
        echo "How many video IDs would ye like t' grab from each channel?"
        echo ""
        echo "=========Type Here==========="
        read -t 30 specifynum
        echo "============================="
        echo ""
        runcount=1
        ###SORT AND SHUFFLE LISTS###
        if [[ -f "$scraperdir/videos.txt" ]]; then
            tr -cd '\11\12\15\40-\176' < videos.txt > videos.txt_tmp && mv videos.txt_tmp videos.txt
            sort -u videos.txt > videos.txt_tmp && mv videos.txt_tmp videos.txt
            shuf videos.txt > videos.txt_tmp && mv videos.txt_tmp videos.txt
        else
            echo "jNQXAC9IVRw" > "$scraperdir/videos.txt"
        fi
        if [[ -f "$scraperdir/channels.txt" ]]; then
            tr -cd '\11\12\15\40-\176' < channels.txt > channels.txt_tmp && mv channels.txt_tmp channels.txt
            sort -u channels.txt > channels.txt_tmp && mv channels.txt_tmp channels.txt
            shuf channels.txt > channels.txt_tmp && mv channels.txt_tmp channels.txt
        else
            echo "UC4QobU6STFB0P71PMvOGN5A" > "$scraperdir/channels.txt"
        fi
        while : 
        do
            if [[ $specifynum == "" ]]; then
                num=$((1 + $RANDOM % 1000))
            else
                num=$specifynum
            fi
            vidtotal=$(wc -l "$scraperdir/videos.txt"  | cut -d " " -f 1)
            ###SELECT A VIDEO THAT HAS NO ERROR###
            while :
            do
                vidselection=$(( 1 + $RANDOM % $vidtotal))
                videoid=$(awk 'NR=='$vidselection'' "$scraperdir/videos.txt")
                checkerror=$(curl -s https://$invidious/api/v1/videos/$videoid | jq -r '.error' 2> /dev/null)
                if [[ $checkerror == "null" || $checkerror == *"in your country"* ]]; then
                    break
                fi
            done
            ###GET RECOMMENDED###
            curl -s https://$invidious/api/v1/videos/$videoid?fields=recommendedVideos | jq -r '.recommendedVideos[].videoId' 2> /dev/null >> videos.txt
            curl -s https://$invidious/api/v1/videos/$videoid?fields=recommendedVideos | jq -r '.recommendedVideos[].authorId' 2> /dev/null >> channels.txt
            ###DOWNLOAD VIDEO METADATA###
            source $scraperdir/youtube_scraper_download_video_metadata.sh
            ###GET VIDEO IDS###
            echo -n "Scrapin' $num video IDs from $channelname ($channelid)..."
            origvidcount=$(wc -l "$scraperdir/videos.txt" | cut -d " " -f 1)
            yt-dlp --geo-bypass --playlist-end $num --flat-playlist --get-id "https://www.youtube.com/channel/$channelid/videos" >> "$scraperdir/videos.txt"
            newvidcount=$(wc -l "$scraperdir/videos.txt" | cut -d " " -f 1)
            scrapecount=$(($newvidcount - $origvidcount))
            echo "...successfully scraped $scrapecount video IDs!"
            ###GET STATISTICS###
            videocount=$(wc -l "$scraperdir/videos.txt" | cut -d " " -f 1)
            channelcount=$(wc -l "$scraperdir/channels.txt" | cut -d " " -f 1)
            metadatacount=$(wc -l "$scraperdir/metadata/youtube_video_dates.csv" | cut -d " " -f 1)
            echo ""
            echo "--- Statistics ---"
            echo ""
            echo "Channel IDs - $channelcount"
            echo "Video IDs - $videocount"
            echo "Video Metadata - $metadatacount"
            echo ""
            echo "Would ye like t' continue scrapin'? (y/N)"
            echo ""
            echo "=========Type Here==========="
            read -t 3 continue
            echo "============================="
            echo ""
            if [[ $continue == "y" || $continue == "" ]]; then
                runcount=$(($runcount + 1))
                if [[ $runcount == "10" ]]; then
                    source "$scraperdir/select_invidious_instance.sh"
                    ###SORT AND SHUFFLE LISTS###
                    echo -n "Sorting and shuffling lists..."
                    sort -u videos.txt > videos.txt_tmp && mv videos.txt_tmp videos.txt
                    shuf videos.txt > videos.txt_tmp && mv videos.txt_tmp videos.txt
                    sort -u channels.txt > channels.txt_tmp && mv channels.txt_tmp channels.txt
                    shuf channels.txt > channels.txt_tmp && mv channels.txt_tmp channels.txt
                    runcount=1
                    echo "...complete!"
                    echo ""
                fi
            else
  
                break
            fi
        done
    fi
fi

###DOWNLOAD VIDEO###
if [[ $mainoption == "3" ]]; then
    echo ""
    echo "Enter th' ID fer the video ye want t' download"
    echo ""
    echo "=========Type Here==========="
    read videoid
    echo "============================="
    channelid=$(curl -s https://$invidious/api/v1/videos/$videoid | jq -r '.authorId' 2> /dev/null)    
    checkiferror=$(curl -s https://$invidious/api/v1/channels/$channelid | jq -r '.error' 2> /dev/null)
    if [[ $checkiferror == "null" ]]; then
        ###DOWNLOAD VIDEO METADATA###
        source $scraperdir/youtube_scraper_download_video_metadata.sh
        ###DOWNLOAD VIDEO###
        source $scraperdir/youtube_scraper_download_video.sh
        ###GENERATE HTML PAGE###
        echo "<title>The Pirate Sea | $title </title>" > "$scraperdir/pages/$videoid.html"                
        echo "<style>" >> "$scraperdir/pages/$videoid.html"
        echo 'a {color: FFFFFF;}' >> "$scraperdir/pages/$videoid.html"                
        echo 'body {background-color: 303030; color: FFFFFF; width: 95%;}' >> "$scraperdir/pages/$videoid.html"
        echo "</style>" >> "$scraperdir/pages/$videoid.html"
        echo '<h1>'$title'</h1>' >> "$scraperdir/pages/$videoid.html"
        echo '<h3>'$videoid'</h3>' >> "$scraperdir/pages/$videoid.html"
        echo '<p><video controls><source src="'$scraperdir'/videos/'$sha256sum'" type="video/mp4"></video></p>' >> "$scraperdir/pages/$videoid.html"
        echo "<p><b>$channelname ($channelid)</b></p>" >> "$scraperdir/pages/$videoid.html"
        echo "<p><b><i>$date</i></b></p>" >> "$scraperdir/pages/$videoid.html"
        echo "<p>$description</p>" >> "$scraperdir/pages/$videoid.html"
        xdg-open "$scraperdir/pages/$videoid.html"
        echo ""
    else
        echo "There seems to be a problem fetching info for that video. Either it has been removed from youtube, or there's something wrong with your current Invidious instance"      
    fi
fi
###COMMENT###
if [[ $mainoption == "4" ]]; then
    echo ""
    echo "What video ye want t' leave a comment on?"
    echo ""
    echo "=========Type Here==========="
    read videoid
    echo "============================="
    ###DOWNLOAD VIDEO METADATA###
    source $scraperdir/youtube_scraper_download_video_metadata.sh
    echo ""
    echo "Please enter a username. Leave blank to post anonymously."
    echo ""
    echo "=========Type Here==========="
    read username
    echo "============================="
    if [[ $username == "" ]]; then
        username="anonymous"
    fi
    fixedusername=$(echo $username | sed 's/|//g')
    username=$fixedusername
    echo ""
    echo "Please enter a comment."
    echo ""
    echo "=========Type Here==========="
    read comment
    echo "============================="
    fixedcomment=$(echo $comment | sed 's/|//g')
    comment=$fixedcomment
    source get_time.sh
    echo ""
    echo "Would ye like t' post this comment on $videoid? (y/N)"
    echo ""
    echo "$username @ $internettime UTC"
    echo ""
    echo "$comment"
    echo ""
    echo "=========Type Here==========="
    read postcomment
    echo "============================="
    if [[ $postcomment == "y" ]]; then
        char=`echo -n "$internetepochtime" | awk '{print substr($0,9,1)}'`
        echo "$videoid|$internetepochtime|$username|$comment-$char" > comment.txt_tmp
        echo "$videoid|$internetepochtime|$username|$comment" >> "$scraperdir/metadata/comments.csv"
        hash=$(sha256sum comment.txt_tmp | cut -d " " -f "1")
        echo "$hash" >> "$scraperdir/metadata/comments_hash.csv"
        rm comment.txt_tmp
    fi
        
fi
###FAVORITES###
if [[ $mainoption == "5" ]]; then
    echo ""
    echo "What ye want t' do wit yer favorites?"
    echo ""
    echo "1) Add video"
    echo "2) Add channel"
    echo "3) Check exising channels for new uploads"
    echo ""
    echo "=========Type Here==========="
    read selection
    echo "============================="
    if [[ $selection == "1" ]]; then
        echo ""
        echo "What video ye want t' download?"
        echo ""
    fi
fi

###MERGE METADATA###
if [[ $mainoption == "6" ]]; then
    source "$scraperdir/merge_metadata.sh"
fi

source "$scraperdir/youtube_scraper.sh"
