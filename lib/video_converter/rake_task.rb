require 'rake'
require 'rake/tasklib'
require_relative File.join('..', 'video_converter', 'converter')

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
  #     logs_folder: '~/logs/video_converter'
  #   )
  class RakeTask < Rake::TaskLib
    def initialize(
      name = :convert_videos,
      verbose: false,
      foreground: false,
      clean: true,
      input_folder: VideoConverter::Converter::DEFAULT_FOLDER,
      output_folder: VideoConverter::Converter::DEFAULT_OUTPUT_FOLDER,
      log_folder: VideoConverter::Converter::DEFAULT_LOG_FOLDER
    )
      desc 'Convert videos'
      task name do
        converter = VideoConverter::Converter.new(
          verbose: verbose,
          foreground: foreground,
          clean: clean,
          input_folder: input_folder,
          log_folder: log_folder,
          output_folder: output_folder
        )
        converter.run
      end
    end
  end
end
