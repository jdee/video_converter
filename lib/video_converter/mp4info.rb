require 'open3'
require_relative File.join('core_ext', 'string')

module VideoConverter
  # Module wrapping the mp4info command to extract information
  # about an MP4 video file.
  module MP4Info
    # Get the output of mp4info for path. Caches the results.
    # Automatically reruns the command if the file has been
    # updated since the last invocation.
    #
    # @param path [String] Path to an MP4 video file
    # @return [String] Output of the mp4info command for the path
    def mp4info_output(path)
      return '' unless path.is_mp4? && File.exist?(path)

      @mp4info_time = {} if @mp4info_time.nil?
      @mp4info_output = {} if @mp4info_output.nil?

      path = File.expand_path path

      # Rerun mp4info if the file has been modified since the last invocation.
      mtime = File.mtime path
      return @mp4info_output[path] unless @mp4info_output[path].nil? || @mp4info_time[path] < mtime

      Open3.popen2e 'mp4info', path do |_input, output, wait_thr|
        lines = output.readlines
        @mp4info_time[path] = Time.now
        if !wait_thr.value.success? || lines.first =~ /can't open/
          @mp4info_output[path] = ''
        else
          @mp4info_output[path] = lines.join("\n")
        end
      end
    end

    # Clear any cached mp4info output for path. If path is
    # nil, clear all cached output.
    #
    # @param path [String, nil] Path to an MP4 video file or nil
    # @return [String, nil] Cached output after deletion or nil if path is nil
    def clear_mp4info_output(path = nil)
      if path.nil?
        @mp4info_time = {}
        @mp4info_output = {}
        return nil
      end

      path = File.expand_path path
      @mp4info_time = {} if @mp4info_time.nil?
      @mp4info_output = {} if @mp4info_output.nil?
      @mp4info_time.delete path
      @mp4info_output.delete path
    end

    # Returns the dimensions of the video at path as an Array.
    #
    # @param path [String] Path to an MP4 video file
    # @return [Array] An Array containing width and height of the video in pixels
    def dimensions(path)
      mp4info_output(path).split("\n").each do |line|
        matches = /video.*\s(\d+)x(\d+)\s/.match line
        next if matches.nil?

        return [matches[1].to_f, matches[2].to_f]
      end
      [nil, nil]
    end

    # Get the formatted audio or video bitrate from the MP4 video
    # file at path.
    #
    # @param path [String] Path to an MP4 video file
    # @param type [#to_s] :audio or :video
    # @return [String] The formatted bitrate from the mp4info output
    def formatted_bitrate(path, type)
      mp4info_output(path).split("\n").each do |line|
        next unless line =~ /\d\t#{type}/

        return line.split(',')[2].strip
      end

      '(not found)'
    end

    # Get the formatted audio bitrate from the MP4 video
    # file at path.
    #
    # @param path [String] Path to an MP4 video file
    # @return [String] The formatted audio bitrate from the mp4info output
    def formatted_audio_bitrate(path)
      formatted_bitrate path, :audio
    end

    # Get the formatted video bitrate from the MP4 video
    # file at path.
    #
    # @param path [String] Path to an MP4 video file
    # @return [String] The formatted video bitrate from the mp4info output
    def formatted_video_bitrate(path)
      formatted_bitrate path, :video
    end

    # Get the numeric audio or video bitrate from the MP4 video
    # file at path.
    #
    # @param path [String] Path to an MP4 video file
    # @param type [#to_s] :audio or :video
    # @return [Float] The audio or video bitrate of the MP4 file
    def bitrate(path, type)
      formatted = formatted_bitrate(path, type).sub(/bps$/, '')

      case formatted
      when /M$/
        formatted.sub(/M$/, '').strip.to_f * 1_000_000.0
      when /k$/
        formatted.sub(/k$/, '').strip.to_f * 1000.0
      else
        formatted.strip.to_f
      end
    end

    # Get the numeric audio bitrate from the MP4 video
    # file at path.
    #
    # @param path [String] Path to an MP4 video file
    # @return [Float] The audio bitrate of the MP4 file
    def audio_bitrate(path)
      bitrate path, :audio
    end

    # Get the numeric video bitrate from the MP4 video
    # file at path.
    #
    # @param path [String] Path to an MP4 video file
    # @return [Float] The video bitrate of the MP4 file
    def video_bitrate(path)
      bitrate path, :video
    end
  end
end
