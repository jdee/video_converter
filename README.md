# video_converter gem

[![License](https://img.shields.io/badge/license-MIT-green.svg?style=flat)](https://github.com/jdee/video_converter/blob/master/LICENSE)
[![CircleCI](https://img.shields.io/circleci/project/github/jdee/video_converter.svg)](https://circleci.com/gh/jdee/video_converter)

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

MP4 files are generated using the H.264 codec using a CRF that may be specified
as an option. Legal values are 0-51. Recommended values are 18-28. The default
is 28. Override this using the `-c` option.

By default, the command starts a backround job and leaves log files in a folder
(~/logs/video_converter by default, overridden with the `-l` option). It
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

### Non-macOS install

Install `ffmpeg` and `mp4v2` manually in order to use this utility. When
running `convert_videos` in the background, no
notification will be generated. If `ffmpeg` and `mp4v2` are not available,
this is a fatal error unless they can be installed automatically via `brew`.

## Try it out

Convert all videos in `~/Downloads`, generating output in `~/Desktop`.

```bash
git clone https://github.com/jdee/video_converter
cd video_converter
bundle check || bundle install
bundle exec rake convert
```

## Build and install the gem

```bash
$ bundle check || bundle install
$ [sudo] bundle exec rake install:local
```

## CLI Usage

```bash
$ convert_videos -h
```

### Convert VOB videos in /Volumes/DVD/VIDEO_TS and output to ~/Desktop

The default input folder is `~/Downloads`.

```bash
$ convert_videos -f /Volumes/DVD/VIDEO_TS
```

### Specify a custom output folder

The default output folder is '~/Desktop'.

```bash
$ convert_videos -o ~/myvideos
```

### Specify a custom log folder

The default log folder is '~/logs/video_converter'.

```bash
$ convert_videos -l ~/mylogs
```

### Convert videos in the foreground and write to a custom output folder

```bash
$ convert_videos -Fo ~/myvideos
```

### Convert videos with a CRF of 23

```bash
$ convert_videos -c 23
```

## Environment variables

All modes of invocation (CLI, Rake, Ruby) recognize the following environment
variables:

```
VIDEO_CONVERTER_VERBOSE
VIDEO_CONVERTER_FOREGROUND
VIDEO_CONVERTER_CLEAN
VIDEO_CONVERTER_FOLDER
VIDEO_CONVERTER_LOG_FOLDER
VIDEO_CONVERTER_OUTPUT_FOLDER
VIDEO_CONVERTER_CRF
```

The first three all represent Boolean flags. Any value starting with y or
t (case-insensitive) indicates a value of true. Any other value will be
interpreted as false.

## With a Gemfile

```Ruby
source 'https://rubygems.org'

gem 'rake', '~> 12.3' # If you want the Rake task
gem 'video_converter', path: '~/video_converter'
```

```bash
$ bundle check || bundle install
$ bundle exec bin/convert_videos -h
```

## Rake task

```Ruby
# Add to Rakefile
require 'video_converter/rake_task'
VideoConverter::RakeTask.new(
  :convert_videos,
  verbose: false,
  foreground: false,
  clean: true,
  input_folder: '~/Downloads',
  output_folder: '~/Desktop',
  log_folder: '~/logs/video_converter',
  crf: 28.0
)
```

```bash
$ rake convert_videos
```

## Ruby code

```Ruby
require 'video_converter/converter'
VideoConverter::Converter.new(
  verbose: false,
  foreground: false,
  clean: true,
  input_folder: '~/Downloads',
  log_folder: '~/logs/video_converter',
  output_folder: '~/Desktop',
  crf: 28.0
).run
```
