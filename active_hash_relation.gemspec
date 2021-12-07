# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'active_hash_relation/version'

Gem::Specification.new do |spec|
  spec.name          = "active_hash_relation"
  spec.version       = ActiveHashRelation::VERSION
  spec.authors       = ["Filippos Vasilakis", "Odd Camp"]
  spec.email         = ["vasilakisfil@gmail.com", "hello@oddcamp.com"]
  spec.summary       = %q{Simple gem that allows you to run multiple ActiveRecord::Relation using hash. Perfect for APIs.}
  spec.description   = spec.summary
  spec.homepage      = "https://github.com/oddcamp/active_hash_relation"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "activerecord"

  spec.add_development_dependency "activerecord"
  spec.add_development_dependency "bundler", "~> 2.1"
  spec.add_development_dependency "rake", "~> 10.0"

  spec.add_development_dependency 'rspec'
  spec.add_development_dependency "factory_bot_rails", "~> 6.2"
  spec.add_development_dependency 'faker'
  spec.add_development_dependency 'database_cleaner'
  spec.add_development_dependency 'pry'
  spec.add_development_dependency 'sqlite3'
  spec.add_development_dependency 'pg'
  spec.add_development_dependency 'rails'
  spec.add_development_dependency 'rspec-rails'
end
