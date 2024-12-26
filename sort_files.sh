#!/bin/bash
echo -n "Sorting files, please wait..."

tr -d '\000' < "$scraperdir/metadata/videos.txt" > "$scraperdir/metadata/videos.txt_tmp" && mv "$scraperdir/metadata/videos.txt_tmp" "$scraperdir/metadata/videos.txt"
tr -d '\000' < "$scraperdir/metadata/videos_archived.txt" > "$scraperdir/metadata/videos_archived.txt_tmp" && mv "$scraperdir/metadata/videos_archived.txt_tmp" "$scraperdir/metadata/videos_archived.txt"
tr -d '\000' < "$scraperdir/metadata/channels.txt" > "$scraperdir/metadata/channels.txt_tmp" && mv "$scraperdir/metadata/channels.txt_tmp" "$scraperdir/metadata/channels.txt"
tr -d '\000' < "$scraperdir/metadata/channels_archived.txt" > "$scraperdir/metadata/channels_archived.txt_tmp" && mv "$scraperdir/metadata/channels_archived.txt_tmp" "$scraperdir/metadata/channels_archived.txt"

tr -d '\000' < "$scraperdir/metadata/youtubeid.csv" > "$scraperdir/metadata/youtubeid.csv_tmp" && mv "$scraperdir/metadata/youtubeid.csv_tmp" "$scraperdir/metadata/youtubeid.csv"
tr -d '\000' < "$scraperdir/metadata/youtube_video_dates.csv" > "$scraperdir/metadata/youtube_video_dates.csv_tmp" && mv "$scraperdir/metadata/youtube_video_dates.csv_tmp" "$scraperdir/metadata/youtube_video_dates.csv"
tr -d '\000' < "$scraperdir/metadata/youtube_video_titles.csv" > "$scraperdir/metadata/youtube_video_titles.csv_tmp" && mv "$scraperdir/metadata/youtube_video_titles.csv_tmp" "$scraperdir/metadata/youtube_video_titles.csv"
tr -d '\000' < "$scraperdir/metadata/youtube_video_descriptions.csv" > "$scraperdir/metadata/youtube_video_descriptions.csv_tmp" && mv "$scraperdir/metadata/youtube_video_descriptions.csv_tmp" "$scraperdir/metadata/youtube_video_descriptions.csv"
tr -d '\000' < "$scraperdir/metadata/youtube_video_uploaders.csv" > "$scraperdir/metadata/youtube_video_uploaders.csv_tmp" && mv "$scraperdir/metadata/youtube_video_uploaders.csv_tmp" "$scraperdir/metadata/youtube_video_uploaders.csv"
tr -d '\000' < "$scraperdir/metadata/youtube_channel_names.csv" > "$scraperdir/metadata/youtube_channel_names.csv_tmp" && mv "$scraperdir/metadata/youtube_channel_names.csv_tmp" "$scraperdir/metadata/youtube_channel_names.csv"
tr -d '\000' < "$scraperdir/metadata/youtube_channel_descriptions.csv" > "$scraperdir/metadata/youtube_channel_descriptions.csv_tmp" && mv "$scraperdir/metadata/youtube_channel_descriptions.csv_tmp" "$scraperdir/metadata/youtube_channel_descriptions.csv"




sort -u "$scraperdir/metadata/videos.txt" > "$scraperdir/metadata/videos.txt_tmp" && mv "$scraperdir/metadata/videos.txt_tmp" "$scraperdir/metadata/videos.txt"
sort -u "$scraperdir/metadata/videos_archived.txt" > "$scraperdir/metadata/videos_archived.txt_tmp" && mv "$scraperdir/metadata/videos_archived.txt_tmp" "$scraperdir/metadata/videos_archived.txt"
sort -u "$scraperdir/metadata/channels.txt" > "$scraperdir/metadata/channels.txt_tmp" && mv "$scraperdir/metadata/channels.txt_tmp" "$scraperdir/metadata/channels.txt"
sort -u "$scraperdir/metadata/channels_archived.txt" > "$scraperdir/metadata/channels_archived.txt_tmp" && mv "$scraperdir/metadata/channels_archived.txt_tmp" "$scraperdir/metadata/channels_archived.txt"

sort -u "$scraperdir/metadata/youtubeid.csv" > "$scraperdir/metadata/youtubeid.csv_tmp" && mv "$scraperdir/metadata/youtubeid.csv_tmp" "$scraperdir/metadata/youtubeid.csv"
sort -u "$scraperdir/metadata/youtube_video_dates.csv" > "$scraperdir/metadata/youtube_video_dates.csv_tmp" && mv "$scraperdir/metadata/youtube_video_dates.csv_tmp" "$scraperdir/metadata/youtube_video_dates.csv"
sort -u "$scraperdir/metadata/youtube_video_titles.csv" > "$scraperdir/metadata/youtube_video_titles.csv_tmp" && mv "$scraperdir/metadata/youtube_video_titles.csv_tmp" "$scraperdir/metadata/youtube_video_titles.csv"
sort -u "$scraperdir/metadata/youtube_video_descriptions.csv" > "$scraperdir/metadata/youtube_video_descriptions.csv_tmp" && mv "$scraperdir/metadata/youtube_video_descriptions.csv_tmp" "$scraperdir/metadata/youtube_video_descriptions.csv"
sort -u "$scraperdir/metadata/youtube_video_uploaders.csv" > "$scraperdir/metadata/youtube_video_uploaders.csv_tmp" && mv "$scraperdir/metadata/youtube_video_uploaders.csv_tmp" "$scraperdir/metadata/youtube_video_uploaders.csv"
sort -u "$scraperdir/metadata/youtube_channel_names.csv" > "$scraperdir/metadata/youtube_channel_names.csv_tmp" && mv "$scraperdir/metadata/youtube_channel_names.csv_tmp" "$scraperdir/metadata/youtube_channel_names.csv"
sort -u "$scraperdir/metadata/youtube_channel_descriptions.csv" > "$scraperdir/metadata/youtube_channel_descriptions.csv_tmp" && mv "$scraperdir/metadata/youtube_channel_descriptions.csv_tmp" "$scraperdir/metadata/youtube_channel_descriptions.csv"

echo "complete!"
