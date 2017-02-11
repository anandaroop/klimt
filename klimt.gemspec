# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'klimt/version'

Gem::Specification.new do |spec|
  spec.name          = 'klimt'
  spec.version       = Klimt::VERSION
  spec.authors       = ['Anandaroop Roy']
  spec.email         = ['anandaroop.roy+github@gmail.com']

  spec.summary       = 'CLI for the Artsy API'
  spec.homepage      = 'https://github.com/anandaroop/klimt'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.13'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'byebug', '~> 9.0'
  spec.add_development_dependency 'webmock', '~> 2.3'
  spec.add_development_dependency 'rubocop', '~> 0.47'

  spec.add_runtime_dependency 'thor', '~> 0.19'
  spec.add_runtime_dependency 'netrc', '~> 0.11'
  spec.add_runtime_dependency 'highline', '~> 1.7'
  spec.add_runtime_dependency 'typhoeus', '~> 1.1'
  spec.add_runtime_dependency 'thor-zsh_completion', '~> 0.1'
end
