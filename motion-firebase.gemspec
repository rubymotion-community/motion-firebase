# -*- encoding: utf-8 -*-
require File.expand_path('../lib/firebase/version.rb', __FILE__)

Gem::Specification.new do |gem|
  gem.name          = 'motion-firebase'
  gem.version       = Motion::Firebase::Version
  gem.licenses      = ['BSD']

  gem.authors = ['Colin T.A. Gray']
  gem.email   = ['colinta@gmail.com']
  gem.summary       = 'A RubyMotion wrapper for the Firebase iOS SDK'
  gem.description = <<-DESC
A RubyMotion wrapper for the Firebase iOS SDK
DESC

  gem.homepage    = 'https://github.com/colinta/motion-firebase'

  gem.files        = Dir.glob('lib/**/*') + ['README.md', 'motion-firebase.gemspec']
  gem.test_files   = gem.files.grep(%r{^spec/})

  gem.require_paths = ['lib']

  gem.add_development_dependency 'rspec'
end