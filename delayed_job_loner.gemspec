# -*- encoding: utf-8 -*-
require File.expand_path('../lib/delayed_job_loner/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Ian Ehlert"]
  gem.email         = ["ian.ehlert@sportngin.com"]
  gem.description   = %q{Gem that adds the ability to prevent duplicate delayed jobs from being created.}
  gem.summary       = %q{Adds an option on handle_asynchronously or delay that specifies which attributes to check for uniqueness on. A new job will not be created if one already exists for that method and object.}
  gem.homepage      = "https://github.com/sportngin/delayed_job_loner"

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "delayed_job_loner"
  gem.require_paths = ["lib"]
  gem.version       = DelayedJobLoner::VERSION
  gem.license       = "MIT"

  gem.add_dependency 'delayed_job'

  gem.add_development_dependency 'rspec'
  gem.add_development_dependency 'rails'
  gem.add_development_dependency 'sqlite3-ruby'
  gem.add_development_dependency 'sqlite3_ar_regexp'
  gem.add_development_dependency 'delayed_job_active_record'
end
