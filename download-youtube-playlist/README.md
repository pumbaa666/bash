# Download Youtube Playlist

## Source

https://github.com/yt-dlp/yt-dlp/wiki/Installation

https://www.youtube.com/watch?v=5qi-Cr5c3bI&list=PL43OynbWaTMKBiJHlz-lrEClg4QF0drtK&index=31

## Description

## Requirements

- ffmpeg
Used to merge audio and video streams, and to convert formats if necessary.
```bash
sudo apt-get install ffmpeg
```

- yt-dlp
Youtube downloader that supports downloading playlists, channels, and more.
```bash
curl -L https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp -o ~/.local/bin/yt-dlp
chmod a+rx ~/.local/bin/yt-dlp  # Make executable
```

## Usage

```bash
./yt-playlist-dl.sh -u "https://www.youtube.com/playlist?list=<PLAYLIST_ID>" -o "/path/to/output/directory"
```
