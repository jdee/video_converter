require 'rake'
require 'rake/tasklib'
# TODO: Refactor all this
# require_relative File.join('..', 'video_converter')

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
    def initialize(name = :convert_videos, input: '~/Downloads', output: '~/Desktop', logs: '~/logs/convert_videos')
      desc 'Convert videos'
      task name do
        system(
          'convert_videos',
          "--folder=#{File.expand_path input}",
          "--output-folder=#{File.expand_path output}",
          "--log-folder=#{File.expand_path logs}"
        )
      end
    end
  end
end
