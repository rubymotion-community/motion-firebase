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
Adds more rubyesque methods to the built-in classes.
DESC

  gem.homepage    = 'https://github.com/colinta/motion-firebase'

  gem.files        = Dir.glob('lib/**/*.rb') + Dir.glob('lib/vendor/**/*') + ['README.md']
  gem.test_files   = gem.files.grep(%r{^spec/})

  gem.require_paths = ['lib']
end
