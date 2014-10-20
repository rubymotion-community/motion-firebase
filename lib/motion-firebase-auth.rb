unless defined?(Motion::Project::Config)
  raise "The motion-firebase-auth gem must be required within a RubyMotion project Rakefile."
end


Motion::Project::App.setup do |app|
  app.info 'Firebase', 'As of version 1.2.2 of Firebase (motion-firebase version 3.0.0), you no'
  app.info '',         'longer need to include motion-firebase-auth, because FirebaseSimpleLogin'
  app.info '',         'is part of the core Firebase SDK.'
end
