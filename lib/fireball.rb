unless defined?(Motion::Project::Config)
  raise "The fireball gem must be required within a RubyMotion project Rakefile."
end


Motion::Project::App.setup do |app|
  # scans app.files until it finds app/ (the default)
  # if found, it inserts just before those files, otherwise it will insert to
  # the end of the list
  insert_point = 0
  app.files.each_index do |index|
    file = app.files[index]
    if file =~ /^(?:\.\/)?app\//
      # found app/, so stop looking
      break
    end
    insert_point = index + 1
  end

  Dir.glob(File.join(File.dirname(__FILE__), 'fireball/**/*.rb')).reverse.each do |file|
    app.files.insert(insert_point, file)
  end

  app.vendor_project(File.join(File.dirname(__FILE__), 'vendor/Firebase.framework'), :static, headers_dir: 'Headers', products: ['Firebase'])
  app.libs << '/usr/lib/libicucore.dylib'
  app.frameworks << 'CFNetwork.framework'
  app.frameworks << 'Security.framework'
  app.frameworks << 'Foundation.framework'
end