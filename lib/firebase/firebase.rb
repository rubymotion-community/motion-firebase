class Firebase
  ERRORS = {
    -9999 => :email_in_use,
    -2 => :wrong_password,
  }

  def self.convert_event_type(event_type)
    case event_type
    when :child_added, :added, FIRDataEventTypeChildAdded
      return FIRDataEventTypeChildAdded

    when :child_moved, :moved, FIRDataEventTypeChildMoved
      return FIRDataEventTypeChildMoved

    when :child_changed, :changed, FIRDataEventTypeChildChanged
      return FIRDataEventTypeChildChanged

    when :child_removed, :removed, FIRDataEventTypeChildRemoved
      return FIRDataEventTypeChildRemoved

    when :value, FIRDataEventTypeValue
      return FIRDataEventTypeValue

    else
      NSLog("Unknown event type #{event_type.inspect}")
      
    end
    return event_type
  end

  def self.url=(url)
    raise "method deprecated"
  end

  def self.configure(options={})
    FIRApp.configure
  end

  def self.database(options={})
    path = options[:path] || nil
    if path
      FIRDatabase.database.reference.child(path)
    else
      FIRDatabase.database.reference
    end
  end

  def self.auth
    FIRAuth.auth
  end

end
