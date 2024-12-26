# The Pirate Sea - Youtube Scraper

## About: 
This is a tool written 100% in BASH that scrapes Youtube and organizes the data into a format that can be easily merged into The Pirate Sea. 

## Prerequisites: 
- Linux with BASH
- curl
- jq
- youtube-dlp
- ffmpeg
- xdg-open (for automatically opening generated HTML pages)

## Features: 
**ID collection:** Utilize recommended video section to bulk collect video and channel IDs.

**Metadata scraping:** Scan through video IDs and store the title, upload date, description and uploader channel ID. Also store channel names and descriptions. 

**Full channel/playlist mirroring:** Input a channel or playlist ID and the script will automatically grab metadata from a specified number of videos, optionally download the actual video file and then output an HTML file of all videos organized by upload date.

**Commenting [experimental]:** A p2p comment layer between users of TPS. 

## Uses: 
**Archiving:** Sick of channels and videos you enjoy getting removed? Ensure you always have a copy of the videos and metadata saved, regardless of what happens to them

**Offline Access:** Download all of your favorite channels and access them whether you have an internet connection or not

**Ad-blocking:** You no longer have to worry about whether Google is going to twist your arm to disable adblocking extensions. Local access means an ad-free experience

**Increased Privacy:** By utilizing Invidious and Youtube-DL, you prevent Youtube from obtaining your browser fingerprint. 

## How to run:
>$ git clone https://github.com/thepiratesea/youtube_scraper

>$ bash youtube_scraper.sh
