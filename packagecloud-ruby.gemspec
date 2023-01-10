# -*- encoding: utf-8 -*-

require File.expand_path('../lib/packagecloud/version', __FILE__)

Gem::Specification.new do |gem|
  gem.name          = "packagecloud-ruby"
  gem.version       = Packagecloud::VERSION
  gem.summary       = "library for interacting with packagecloud.io"
  gem.description   = gem.summary
  gem.license       = "APL 2.0"
  gem.authors       = ["Joe Damato"]
  gem.email         = "joe@packagecloud.io"
  gem.homepage      = "https://rubygems.org/gems/packagecloud-ruby"

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ['lib']

  gem.add_runtime_dependency 'excon', '~> 0.40'
  gem.add_runtime_dependency 'json_pure', '~> 2'
  gem.add_runtime_dependency 'mime', '~> 0.4'

  gem.add_development_dependency 'bundler', '~> 2.0'
  gem.add_development_dependency 'rake', '~> 0.8'
  gem.add_development_dependency 'rspec', '~> 2.4'
  gem.add_development_dependency 'simplecov', '~> 0.9'
  gem.add_development_dependency 'rubygems-tasks', '~> 0.2'
  gem.add_development_dependency 'yard', '~> 0.9.11'
end
