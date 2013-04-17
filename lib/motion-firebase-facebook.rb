unless defined?(Motion::Project::Config)
  raise "The motion-firebase-auth gem must be required within a RubyMotion project Rakefile."
end


Motion::Project::App.setup do |app|
  # scans app.files until it finds app/ (the default)
  # if found, it inserts just before those files, otherwise it will insert to
  # the end of the list
  insert_point = app.files.find_index { |file| file =~ /^(?:\.\/)?app\// } || 0

  Dir.glob(File.join(File.dirname(__FILE__), 'firebase-auth/**/*.rb')).reverse.each do |file|
    app.files.insert(insert_point, file)
  end

  app.vendor_project(File.join(File.dirname(__FILE__), 'vendor/FacebookSDK.framework'), :static, headers_dir: 'Headers', products: ['FacebookSDK'])
end
