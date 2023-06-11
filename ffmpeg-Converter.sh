#!/bin/bash

# Function to check if ffmpeg is installed
check_ffmpeg() {
    if ! command -v ffmpeg &> /dev/null; then
        echo "ffmpeg is not installed. Installing..."
        sudo apt update
        sudo apt install ffmpeg -y
        echo "ffmpeg has been installed."
    else
        echo "ffmpeg is already installed."
    fi
}

# Check if ffmpeg is installed
check_ffmpeg

# Loop through all .mp4 files in the current directory
for file in *.mp4; do
    # Check if the file exists and is a regular file
    if [[ -f "$file" ]]; then
        # Get the base name of the file (without extension)
        filename=$(basename -- "$file")
        extension="${filename##*.}"
        filename="${filename%.*}"

        # Create a directory with the same name as the file
        mkdir "$filename"

        # Create directories for different quality formats
        mkdir "$filename/480p"
        mkdir "$filename/720p"
        mkdir "$filename/1080p"

        # Create 480p video and segment files
        ffmpeg -i "$file" -vf "scale=854:480" -c:v h264 -c:a aac -b:v 800k -b:a 128k -hls_time 10 -hls_list_size 0 -hls_segment_filename "$filename/480p/%03d.ts" "$filename/480p/$filename.m3u8"

        # Create 720p video and segment files
        ffmpeg -i "$file" -vf "scale=1280:720" -c:v h264 -c:a aac -b:v 1500k -b:a 128k -hls_time 10 -hls_list_size 0 -hls_segment_filename "$filename/720p/%03d.ts" "$filename/720p/$filename.m3u8"

        # Create 1080p video and segment files
        ffmpeg -i "$file" -vf "scale=1920:1080" -c:v h264 -c:a aac -b:v 3000k -b:a 128k -hls_time 10 -hls_list_size 0 -hls_segment_filename "$filename/1080p/%03d.ts" "$filename/1080p/$filename.m3u8"

        # Create the master playlist file
        master_playlist="$filename/master.m3u8"
        echo "#EXTM3U" > "$master_playlist"
        echo "#EXT-X-STREAM-INF:BANDWIDTH=800000,RESOLUTION=854x480" >> "$master_playlist"
        echo "480p/$filename.m3u8" >> "$master_playlist"
        echo "#EXT-X-STREAM-INF:BANDWIDTH=1500000,RESOLUTION=1280x720" >> "$master_playlist"
        echo "720p/$filename.m3u8" >> "$master_playlist"
        echo "#EXT-X-STREAM-INF:BANDWIDTH=3000000,RESOLUTION=1920x1080" >> "$master_playlist"
        echo "1080p/$filename.m3u8" >> "$master_playlist"

        echo "Created quality formats and master playlist for $filename.mp4"
        echo "Directory: $filename"
    fi
done

