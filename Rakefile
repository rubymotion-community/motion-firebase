# -*- coding: utf-8 -*-
$:.unshift("/Library/RubyMotion/lib")

platform = ENV.fetch('platform', 'ios')
if platform == 'ios'
  require 'motion/project/template/ios'
elsif platform == 'osx'
  require 'motion/project/template/osx'
end

require 'bundler'
Bundler.require


Motion::Project::App.setup do |app|
  # Use `rake config' to see complete project settings.
  app.name = 'motion-firebase'

  app.files.concat Dir.glob("app-#{platform}/**/*")
end
