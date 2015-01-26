# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'active_hash_relation/version'

Gem::Specification.new do |spec|
  spec.name          = "active_hash_relation"
  spec.version       = ActiveHashRelation::VERSION
  spec.authors       = ["Filippos Vasilakis"]
  spec.email         = ["vasilakisfil@gmail.com"]
  spec.summary       = %q{Simple gem that allows you to run multiple ActiveRecord::Relation using hash. Perfect for APIs.}
  spec.description   = spec.summary
  spec.homepage      = "https://www.kollegorna.se"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "rake", "~> 10.0"
end
