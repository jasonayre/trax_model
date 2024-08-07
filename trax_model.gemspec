# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'trax_model/version'

Gem::Specification.new do |spec|
  spec.name          = "trax_model"
  spec.version       = TraxModel::VERSION
  spec.authors       = ["Jason Ayre"]
  spec.email         = ["jasonayre@gmail.com"]
  spec.summary       = %q{Better ActiveRecord attributes, conventions, utilities}
  spec.description   = %q{ActiveRecord attributes DDL, struct/array attribute types, an enum implementation that doesn't suck, etc..}
  spec.homepage      = "http://github.com/jasonayre/trax_model"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "trax_core", "~> 0.0.84"
  spec.add_dependency "default_value_for"
  # spec.add_development_dependency "hashie", ">= 3.4.4"
  spec.add_development_dependency "rails", "~> 5.1.4"
  spec.add_development_dependency "activerecord", "~> 5.1.4"
  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "sqlite3", "~> 1.4.4"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "timecop"
  spec.add_development_dependency "rspec-pride"
  spec.add_development_dependency "pry-nav"
  spec.add_development_dependency "simplecov"
  spec.add_development_dependency 'rspec-its', '~> 1'
  spec.add_development_dependency 'rspec-collection_matchers', '~> 1'
  spec.add_development_dependency "pg"
  spec.add_development_dependency 'guard', '~> 2'
  spec.add_development_dependency 'guard-rspec', '~> 4'
  spec.add_development_dependency 'guard-bundler', '~> 2'
  spec.add_development_dependency 'listen', '~> 3.0.3'
  spec.add_development_dependency 'rb-fsevent', '~> 0.9.6'
  spec.add_development_dependency "ruby_dig"
end
