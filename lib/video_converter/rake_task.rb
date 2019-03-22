require 'rake'
require 'rake/tasklib'
require_relative File.join('..', 'video_converter')

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
  #     :convert,
  #     input: '~/Downloads',
  #     output: '~/Desktop',
  #     logs: '~/logs/convert_videos'
  #   )
  class RakeTask < Rake::TaskLib
    def initialize(
      name = :convert_videos,
      input: VideoConverter::Converter::DEFAULT_FOLDER,
      output: VideoConverter::Converter::DEFAULT_OUTPUT_FOLDER,
      logs: VideoConverter::Converter::DEFAULT_LOG_FOLDER
    )
      desc 'Convert videos'
      task name do
        options = VideoConverter::Converter::Options.new(
          false,
          false,
          true,
          input,
          logs,
          output
        )
        converter = VideoConverter::Converter.new options
        converter.run
      end
    end
  end
end
