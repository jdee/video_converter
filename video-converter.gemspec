lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "video_converter/version"

Gem::Specification.new do |spec|
  spec.name          = 'video-converter'
  spec.version       = VideoConverter::VERSION
  spec.summary       = ''
  spec.description   = ''
  spec.authors       = ['Jimmy Dee']
  spec.email         = ['jgvdthree@gmail.com']

  spec.files         = Dir['bin/*', 'lib/**/*'] + %w{README.md LICENSE}
  spec.test_files    = spec.files.grep(/_spec/)

  spec.require_paths = ['lib']
  spec.bindir        = 'bin'
  spec.executables   = %w{convert_videos check_sizes}

  spec.homepage      = ''
  spec.license       = 'MIT'

  spec.required_ruby_version = '>= 2.2.0'

  spec.add_dependency 'colored', '~> 1.2'

  spec.add_development_dependency 'bundler', '~> 2.0'
  spec.add_development_dependency 'cocoapods', '~> 1.3'
  spec.add_development_dependency 'pry', '~> 0.11'
  spec.add_development_dependency 'rake', '< 13'
  spec.add_development_dependency 'rspec', '~> 3.5'
  spec.add_development_dependency 'rspec-simplecov', '~> 0.2'
  spec.add_development_dependency 'rspec_junit_formatter', '~> 0.3'
  spec.add_development_dependency 'rubocop', '0.65.0'
  spec.add_development_dependency 'simplecov', '~> 0.15'
end