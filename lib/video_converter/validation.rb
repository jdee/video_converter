require 'colored'
require 'fileutils'
require_relative 'mp4info'
require_relative 'util'

module VideoConverter
  module Validation
    THRESHOLD = 0.9

    #
    # Suffixes to use when looking in options.folder for videos to convert.
    # All suffixes are recognized both as all lowercase and all uppercase.
    # For example, myvideo.mp4, myvideo.mov, myvideo.MOV, myvideo.wmv,
    # myvideo.AVI, etc.
    #
    VIDEO_SUFFIXES = %w[mp4 mov avi wmv flv vob].freeze
    REGEXP = /#{VIDEO_SUFFIXES.join("$|")}/i

    ############
    # formatting
    ############

    def formatted_size(size)
      if size < 1024
        "#{size} B"
      elsif size < 1024 * 1024
        "#{format('%.2f', (size / 1024.0 + 0.005))} kB"
      elsif size < 1024 * 1024 * 1024
        "#{format('%.2f', (size / 1024.0 / 1024.0 + 0.005))} MB"
      else
        "#{format('%.2f', (size / 1024.0 / 1024.0 / 1024.0 + 0.005))} GB"
      end
    end

    ##############
    # main program
    ##############

    include VideoConverter::Util
    include VideoConverter::MP4Info

    def all_videos_to_validate
      return @all_videos_to_validate unless @all_videos_to_validate.nil?

      @all_videos_to_validate = Dir[File.join(folder_to_validate, '*.mp4')].sort { |f1, f2| File.mtime(f1) <=> File.mtime(f2) }
    end

    def folder_to_validate
      @options.output_folder
    end

    def base_path(path)
      File.basename(path).sub(REGEXP, 'mp4')
    end

    def check_and_report(old_path, log)
      path = File.join folder_to_validate, base_path(old_path)
      new_size = File.size path
      old_size = File.size old_path

      if new_size >= old_size * THRESHOLD
        log.log "#{path}: #{new_size} (compressed)/#{old_size} (original) #{format('%.2f', (new_size * 100.0 / old_size + 0.005))}%".yellow
      else
        log.log "#{path}: #{new_size} (compressed)/#{old_size} (original) #{format('%.2f', (new_size * 100.0 / old_size + 0.005))}%".green
      end

      if old_path.is_mp4?
        log.log "  audio bitrate: orig #{formatted_audio_bitrate old_path}, converted #{formatted_audio_bitrate path}"
        log.log "  video bitrate: orig #{formatted_video_bitrate old_path}, converted #{formatted_video_bitrate path}"
      else
        log.log "  audio bitrate: converted #{formatted_audio_bitrate path}"
        log.log "  video bitrate: converted #{formatted_video_bitrate path}"
      end

      [old_size, new_size]
    end

    def original_video(path)
      VIDEO_SUFFIXES.each do |suffix|
        old_path = File.join(@options.folder, File.basename(path).sub(/mp4$/, suffix))
        return old_path if File.exist? old_path

        old_path = File.join(@options.folder, File.basename(path).sub(/mp4$/, suffix.upcase))
        return old_path if File.exist? old_path
      end

      nil
    end

    def verbose?
      @options.verbose
    end

    def fix?
      true
    end

    def validate(log)
      exit(1) unless check_commands(:mp4info)

      total_savings = 0
      total_size = 0
      all_videos_to_validate.each do |path|
        old_path = original_video path

        if old_path.nil?
          log.log "original video not found for #{path} in #{@options.folder}".yellow if verbose?
          next
        end

        old_size, new_size = check_and_report old_path, log

        if old_path.is_mp4? && audio_bitrate(path) > audio_bitrate(old_path)
          log.log "  Conversion increased audio bitrate from #{formatted_audio_bitrate old_path} to #{formatted_audio_bitrate path}.".yellow
        end

        if old_path.is_mp4? && video_bitrate(path) > video_bitrate(old_path)
          log.log "  Conversion increased video bitrate from #{formatted_video_bitrate old_path} to #{formatted_video_bitrate path}.".yellow
        end

        if fix? && new_size >= old_size * THRESHOLD && old_path.is_mp4?
          FileUtils.rm_f path
          FileUtils.cp old_path, path
          FileUtils.touch path, mtime: File.mtime(old_path)
          log.log "Copied #{old_path} to #{path}."
          new_size = old_size
        end

        total_savings += old_size - new_size
        total_size += old_size
      end

      unless total_size <= 0
        log.log "Total savings: #{formatted_size total_savings}/#{formatted_size total_size} (#{format('%.2f', (total_savings * 100.0 / total_size + 0.005))}%)"
      end
    end
  end
end
