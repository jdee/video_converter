require 'tmpdir'
require 'tty/platform'
require_relative 'validation'

module VideoConverter
  # Class for video conversion
  #    require 'video_converter/converter'
  #    VideoConverter::Converter.new(
  #      verbose: false,
  #      foreground: false,
  #      clean: true,
  #      input_folder: '~/Downloads',
  #      log_folder: '~/logs/video_converter',
  #      output_folder: '~/Desktop'
  #    ).run
  class Converter
    Options = Struct.new(
      :verbose,
      :foreground,
      :clean,
      :folder,
      :log_folder,
      :output_folder
    )

    DEFAULT_FOLDER = '~/Downloads'
    DEFAULT_LOG_FOLDER = '~/logs/video_converter'
    DEFAULT_OUTPUT_FOLDER = '~/Desktop'

    include Validation

    attr_reader :options

    # Create a new Converter
    #
    # @param options [Options] An Options struct containing configuration
    # @param verbose [true, false] Output additional information at times
    # @param foreground [true, false] Run in the foreground
    # @param clean [true, false] Remove original videos after conversion
    # @param input_folder [String] Folder to scan for input videos
    # @param log_folder [String] Folder for log files (background)
    # @param output_folder [String] Folder for output MP4 files
    def initialize(
      options = nil,
      verbose: false,
      foreground: false,
      clean: true,
      input_folder: DEFAULT_FOLDER,
      log_folder: DEFAULT_LOG_FOLDER,
      output_folder: DEFAULT_OUTPUT_FOLDER
    )
      @options = options || Options.new(
        verbose,
        foreground,
        clean,
        File.expand_path(input_folder),
        File.expand_path(log_folder),
        File.expand_path(output_folder)
      )
    end

    # Perform video conversion
    def run
      if foreground?
        convert_all
      else
        @log_file = File.join options.log_folder, 'convert_videos.log'

        if Process.respond_to? :fork
          pid = fork do
            Process.setpriority Process::PRIO_PROCESS, 0, 19
            STDIN.close # Attempt to avoid SIGHUP

            FileUtils.rm_rf options.log_folder
            FileUtils.mkdir_p options.log_folder

            video_count = all_videos.count
            File.open @log_file, 'w' do |log|
              log.log "Process priority is #{Process.getpriority Process::PRIO_PROCESS, 0} for PID #{Process.pid}."

              first_video = all_videos.first if video_count > 0
              convert_all log: log

              exit(0) unless mac?

              # Generate a preview
              if first_video
                command = make_preview_command output_path(first_video)
                log.log_command command
                system(*command, %i[err out] => File.join(options.log_folder, 'preview.log'))
              end

              notify_user video_count, log
            end
          end
        else
          pid = run_in_background
        end

        unless pid.zero?
          STDOUT.log "Child process is #{pid}. Output in #{@log_file}.", obfuscate: false
          exit 0
        end
      end
    end

    def cli_command
      command = [
        File.expand_path(File.join('bin', 'convert_videos')),
        verbose? ? "--verbose" : "--no-verbose",
        "--foreground",
        "--folder=#{@options.folder}",
        "--output-folder=#{@options.output_folder}",
        "--log-folder=#{@options.log_folder}"
      ]
      command << "--no-clean" unless clean?
      command
    end

    # Portability method. Executes a foregrounded convert_videos process as a background task,
    # similar to how #fork is used when available.
    def run_in_background
      FileUtils.rm_rf @options.log_folder
      FileUtils.mkdir_p @options.log_folder

      pid = spawn(*cli_command, %i[err out] => File.join(@options.log_folder, 'convert_videos.log'))
      if Process.respond_to?(:setpriority) && defined?(Process::PRIO_PROCESS)
        Process.setpriority Process::PRIO_PROCESS, pid, 19
        if Process.respond_to?(:getpriority)
          STDOUT.log "Process priority is #{Process.getpriority Process::PRIO_PROCESS, pid} for PID #{pid}.", obfuscate: false
        end
      end
      pid
    end

    def all_videos
      return @all_videos unless @all_videos.nil?

      full_path = File.expand_path options.folder
      @all_videos = Dir.chdir options.folder do
        VIDEO_SUFFIXES.inject([]) do |all_vids, suffix|
          all_vids + Dir["*.#{suffix.downcase}"] + Dir["*.#{suffix.upcase}"]
        end
      end.map { |f| File.join full_path, f }
    end

    def print_to_be_converted(log)
      return unless verbose?

      log.log 'To be converted:'
      all_videos.each do |v|
        log.log "  #{v}"
      end
    end

    def conversion_command(path, output_path, type: nil)
      conversions =
        case type
        when Array
          type.map(&:to_sym)
        when Symbol
          [type]
        when String
          [type.to_sym]
        else
          %i[audio video]
        end

      command = ['ffmpeg', '-i', path]

      if conversions.include? :video
        # Use -crf 28 for H.264 when converting to MP4.
        command += %w[-crf 28] if output_path.is_mp4?
        command += %w[-codec:audio copy] unless conversions.include?(:audio) || output_path.video_type != path.video_type
      end

      if conversions.include? :audio
        command += %w[-codec:video copy] unless conversions.include?(:video) || output_path.video_type != path.video_type
      end

      command + ['-y', output_path]
    end

    # Convert audio without converting video. Writes to file.mp4 in @tmpdir.
    def convert_audio_command(path)
      conversion_command path, temp_path(path), type: :audio
    end

    # Convert video without converting audio. Writes to options.output_folder.
    def convert_video_command(path)
      conversion_command path, output_path(path), type: :video
    end

    def make_preview_command(path)
      width, height = dimensions path
      unless width.nil? || height.nil?
        if width > height
          indent = 0.5 * (width - height)
          crop = "#{height}:#{height}:#{indent}:0"
        else
          indent = 0.5 * (height - width)
          crop = "#{width}:#{width}:0:#{indent}"
        end
      end

      ['ffmpeg', '-i', path, '-f', 'image2', '-filter', "crop=#{crop}", '-vframes', '1', '-y', preview_path]
    end

    def output_path(path)
      File.join(options.output_folder, File.basename(path.sub(REGEXP, 'mp4')))
    end

    def temp_path(path)
      File.join @tmpdir, File.basename(path.sub(REGEXP, 'mp4'))
    end

    def preview_path
      File.join Dir.tmpdir, 'preview.jpg'
    end

    def convert_file(path, log_path, log)
      if path.is_mp4?
        # Convert mp4s in two steps.

        # Step 1: Convert audio without converting video.
        # Generates file.mp4 in a temporary folder.
        command = convert_audio_command path
        log.log_command command
        if log_path
          system(*command, %i[out err] => log_path)
        else
          system(*command)
        end

        # Now determine the audio bitrates of the original and the file in the temp folder.
        orig_audio_bitrate = audio_bitrate path
        converted_audio_bitrate = audio_bitrate temp_path(path)

        # Choose the one with the lower audio bitrate as input for the second step.
        # If the converted bitrate is 90% or more of the original, use the original.
        input = converted_audio_bitrate < orig_audio_bitrate * THRESHOLD ? temp_path(path) : path

        # Step 2: Convert video without converting audio using the original or
        # the temp copy with converted audio, whichever is smaller.
        # Generates file.mp4 in options.output_folder.
        command = convert_video_command input

        log.log_command command
        if log_path
          system(*command, %i[out err] => log_path)
        else
          system(*command)
        end

        FileUtils.rm_f temp_path(path)

        # This results in a file with minimum audio bitrate (original or reduced)
        # and a reduced video bitrate without converting audio or video twice.
      else
        command = conversion_command path, output_path(path)
        log.log_command command
        if log_path
          system(*command, %i[out err] => log_path)
        else
          system(*command)
        end
      end

      FileUtils.touch(output_path(path), mtime: File.mtime(path))

      log.log "Finished converting #{output_path path}.".cyan.bold
    end

    def convert_all(log: STDOUT)
      unless check_commands %i[ffmpeg mp4info], log: log
        log.log 'Please install these packages in order to use this script.'.red.bold
        exit 1
      end

      FileUtils.mkdir_p options.output_folder unless Dir.exist?(options.output_folder)

      Dir.mktmpdir do |dir|
        @tmpdir = dir

        print_to_be_converted log
        all_videos.each do |path|
          if log.respond_to? :path
            log_path = File.join options.log_folder, File.basename(path.sub(REGEXP, 'log'))
            output_path = output_path path
            log.log "input: #{path}, output: #{output_path}, log: #{log_path}" if verbose?
          end

          convert_file path, log_path, log
        end

        log.log 'Finished converting all videos.'.cyan.bold

        # @tmpdir about to be deleted
        remove_instance_variable :@tmpdir
      end

      validate log

      clean_sources log
    end

    def clean_sources(log)
      return unless clean? && File.writable?(options.folder)

      log.log 'Removing:'
      all_videos.each { |v| log.log "  #{v}" }
      FileUtils.rm_f all_videos
    end

    def notify_user(count, log)
      return if count <= 0

      message = "Converted #{count} video#{count > 1 ? 's' : ''}."
      log.log message.cyan.bold

      command = [
        'terminal-notifier',
        '-title',
        'Video Conversion Complete',
        '-message',
        message,
        '-sound',
        'default',
        '-contentImage',
        preview_path,
        '-activate',
        'com.apple.Photos' # ,
        # '-open',
        # "file://#{options.output_folder}"
      ]

      # terminal-notifier is a runtime dependency and so will always be present.
      # On any platform besides macOS, this command will fail.
      system(*command, %i[err out] => :close)

      FileUtils.rm_f preview_path
    end

    def foreground?
      options.foreground
    end

    def clean?
      options.clean
    end

    def mac?
      @platform = TTY::Platform.new if @platform.nil?
      @platform.mac?
    end
  end
end
