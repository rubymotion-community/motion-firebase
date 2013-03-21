# -*- encoding: utf-8 -*-
require File.expand_path('../lib/fireball/version.rb', __FILE__)

Gem::Specification.new do |gem|
  gem.name          = 'fireball'
  gem.version       = Fireball::Version

  gem.authors = ['Colin T.A. Gray']
  gem.email   = ['colinta@gmail.com']
  gem.summary       = 'A RubyMotion wrapper for the Firebase iOS SDK'
  gem.description = <<-DESC
A RubyMotion wrapper for the Firebase iOS SDK
DESC

  gem.homepage    = 'https://github.com/colinta/fireball'

  gem.files        = `git ls-files`.split($\)
  gem.test_files   = gem.files.grep(%r{^spec/})

  gem.require_paths = ['lib']

  gem.add_development_dependency 'rspec'
end