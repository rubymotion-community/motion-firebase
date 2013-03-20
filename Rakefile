# -*- coding: utf-8 -*-
$:.unshift("/Library/RubyMotion/lib")
require 'motion/project'
require 'bundler'
Bundler.require


Motion::Project::App.setup do |app|
  # Use `rake config' to see complete project settings.
  app.name = 'firehose'
  app.vendor_project('vendor/Firebase.framework', :static, headers_dir: 'Headers', products: ['Firebase'])
  app.libs << '/usr/lib/libicucore.dylib'
  app.frameworks << 'CFNetwork.framework'
  app.frameworks << 'Security.framework'
  app.frameworks << 'Foundation.framework'
end
