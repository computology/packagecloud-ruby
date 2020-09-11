require File.expand_path("../lib/packagecloud/version", __FILE__)

Gem::Specification.new do |gem|
  gem.name = "packagecloud-ruby"
  gem.version = Packagecloud::VERSION
  gem.summary = "library for interacting with packagecloud.io"
  gem.description = gem.summary
  gem.license = "APL 2.0"
  gem.authors = ["Joe Damato"]
  gem.email = "joe@packagecloud.io"
  gem.homepage = "https://rubygems.org/gems/packagecloud-ruby"

  gem.files = `git ls-files`.split($/)
  gem.executables = gem.files.grep(%r{^bin/}).map { |f| File.basename(f) }
  gem.test_files = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_runtime_dependency "excon", "~> 0.76"
  gem.add_runtime_dependency "json_pure", "~> 2.3"
  gem.add_runtime_dependency "multi_json", "~> 1.1"
  gem.add_runtime_dependency "mime", "~>0.4"

  gem.add_development_dependency "bundler", "~> 2"
  gem.add_development_dependency "rake", "~> 13"
  gem.add_development_dependency "rspec", "~>3.9"
  gem.add_development_dependency "simplecov", "~>0.19"
  gem.add_development_dependency "rubygems-tasks", "~>0.2.5"
  gem.add_development_dependency "yard", "~> 0.9.25"
  gem.add_development_dependency "standardrb", "~> 1"
end
