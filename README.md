# video-converter gem (macOS only)

## Overview

Batch-converts videos to MP4 format from any recognized format, including MP4.
Converting
MP4 files can be useful to reduce the bitrate. Depends on ffmpeg, mp4v2 and
terminal-notifier from homebrew. Automatically checks for and installs these
dependencies if they are absent at runtime.

The `convert_videos` command scans an input folder (~/Downloads by default,
overridden with the `-f` option) for all video files with
suffixes mp4, mov, avi, wmv, flv and vob. This is done by globbing for both
all-lowercase and all-uppercase suffixes. The command will recognize file.mov
and file.MOV, but not file.Mov. Searching is not recursive.

Output files are always MP4. They will have the same name as the originals, with
suffix .mp4. **Note:** Currently if the input and output folders are the same,
an input MP4 video may be overwritten and lost, causing the conversion
to fail. By default, the output folder
is ~/Desktop. This may be overridden with the `-o` option.

By default, the command starts a backround job and leaves log files in a folder
(~/logs/convert_videos by default, overridden with the `-l` option). It
removes and recreates the folder each time the script runs. It generates a file
there called `convert_videos.log` as well as a log file for each conversion.

To run the command in the foreground, specify `-F` or `--foreground`.

If the script runs in the background, it will use `terminal-notifier` to
generate a desktop notification when it completes. Clicking on the notification
will open the Photos app.

When a source video is MP4, the converted file is compared with the original
after conversion. If the converted file is 90% or more of the original file
size, the original file is copied over the converted file, since the conversion
makes little difference and presumably only degrades quality. Otherwise the
converted file is retained. For non-MP4 source videos, no comparison is made.

Modification times of converted files will always be the same as the originals
after conversion.

After conversion, by default, all source videos are removed from the input
folder if it is writable. Override this behavior using the `--no-clean` option.

## Build and install

```bash
bundle install
[sudo] bundle exec rake install:local
```

## Usage

```bash
convert_videos -h
```

### Convert VOB videos in /Volumes/DVD/VIDEO_TS and output to ~/Desktop

The default input folder is `~/Downloads`.

```bash
convert_videos -f /Volumes/DVD/VIDEO_TS
```

### Specify a custom output folder

The default output folder is '~/Desktop'.

```bash
convert_videos -o ~/myvideos
```

### Specify a custom log folder

The default log folder is '~/logs/convert_videos'.

```bash
convert_videos -l ~/mylogs
```

### Convert videos in the foreground and write to a custom output folder

```bash
convert_videos -Fo ~/myvideos
```
