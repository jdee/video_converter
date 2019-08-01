require 'rake'
require 'rake/tasklib'
require_relative 'converter'

module VideoConverter
  # Rake task for video-converter gem.
  #
  # Rakefile:
  #
  #   require 'video_converter/rake_task'
  #   VideoConverter::RakeTask.new
  #
  # This results in a task called convert_videos with the default options.
  #
  #   # override default options and task name
  #   VideoConverter::RakeTask.new(
  #     :convert_videos,
  #     verbose: false,
  #     foreground: false,
  #     clean: true,
  #     input_folder: '~/Downloads',
  #     output_folder: '~/Desktop',
  #     logs_folder: '~/logs/video_converter',
  #     crf: 28.0
  #   )
  #
  # Recognizes the following environment variables:
  #
  #   VIDEO_CONVERTER_VERBOSE
  #   VIDEO_CONVERTER_FOREGROUND
  #   VIDEO_CONVERTER_CLEAN
  #   VIDEO_CONVERTER_FOLDER
  #   VIDEO_CONVERTER_LOG_FOLDER
  #   VIDEO_CONVERTER_OUTPUT_FOLDER
  #   VIDEO_CONVERTER_CRF
  #
  # The first three all represent Boolean flags. Any value starting with y or
  # t (case-insensitive) indicates a value of true. Any other value will be
  # interpreted as false.

  class RakeTask < Rake::TaskLib
    include Util

    def initialize(
      name = :convert_videos,
      verbose: boolean_env_var?(:VIDEO_CONVERTER_VERBOSE, default_value: false),
      foreground: boolean_env_var?(:VIDEO_CONVERTER_FOREGROUND, default_value: false),
      clean: boolean_env_var?(:VIDEO_CONVERTER_CLEAN, default_value: true),
      input_folder: ENV['VIDEO_CONVERTER_FOLDER'] || VideoConverter::Converter::DEFAULT_FOLDER,
      output_folder: ENV['VIDEO_CONVERTER_OUTPUT_FOLDER'] || VideoConverter::Converter::DEFAULT_OUTPUT_FOLDER,
      log_folder: ENV['VIDEO_CONVERTER_LOG_FOLDER'] || VideoConverter::Converter::DEFAULT_LOG_FOLDER,
      crf: float_env_var(:VIDEO_CONVERTER_CRF, default_value: VideoConverter::Converter::DEFAULT_CRF)
    )
      desc 'Convert videos'
      task name do
        converter = VideoConverter::Converter.new(
          verbose: verbose,
          foreground: foreground,
          clean: clean,
          input_folder: input_folder,
          log_folder: log_folder,
          output_folder: output_folder,
          crf: crf
        )
        converter.run
      end
    end
  end
end
