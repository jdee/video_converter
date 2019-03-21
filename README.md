# video-converter gem

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
