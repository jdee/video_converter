require 'bundler/gem_tasks'

require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new

require 'rubocop/rake_task'
RuboCop::RakeTask.new(:rubocop)

require 'yard'
YARD::Rake::YardocTask.new

LOG_DIR = 'logs'
require_relative File.join('lib', 'video_converter', 'rake_task')
VideoConverter::RakeTask.new(
  :convert,
  # verbose:       true,          # false by default
  # foreground:    true,          # false by default
  # clean:         false,         # true by default
  # input_folder:  '~/Downloads', # default value
  # output_folder: '~/Desktop',   # default value
  log_folder: ENV['VIDEO_CONVERTER_LOG_FOLDER'] || LOG_DIR
)

desc 'Remove all generated files'
task 'clobber:all' => :clobber do
  FileUtils.rm_rf [
    LOG_DIR,
    'coverage',
    'doc',
    '.yardoc',
    '_yardoc',
    'test-results'
  ]
end

task default: [:spec, :rubocop]
