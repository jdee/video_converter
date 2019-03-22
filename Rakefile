require 'bundler/gem_tasks'

require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new

require 'rubocop/rake_task'
RuboCop::RakeTask.new(:rubocop)

require 'yard'
YARD::Rake::YardocTask.new

LOG_DIR = 'logs'
require_relative File.join('lib', 'video_converter', 'rake_task')
VideoConverter::RakeTask.new :convert, logs: LOG_DIR

desc 'Remove all generated files'
task 'clobber:all' do
  Rake::Task[:clobber].invoke
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
