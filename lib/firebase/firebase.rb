class Firebase
  ERRORS = {
    -9999 => :email_in_use,
    -2 => :wrong_password,
  }

  def self.convert_event_type(event_type)
    case event_type
    when :child_added, :added, FEventTypeChildAdded
      return FEventTypeChildAdded
    when :child_moved, :moved, FEventTypeChildMoved
      return FEventTypeChildMoved
    when :child_changed, :changed, FEventTypeChildChanged
      return FEventTypeChildChanged
    when :child_removed, :removed, FEventTypeChildRemoved
      return FEventTypeChildRemoved
    when :value, FEventTypeValue
      return FEventTypeValue
    else
      NSLog("Unknown event type #{event_type.inspect}")
    end
    return event_type
  end

  def self.url=(url)
    if url.start_with?('http://')
      raise "Invalid URL #{url.inspect} in #{__method__}: URL scheme should be 'https://', not 'http://'"
    elsif url.start_with?('https://')
      # all good
    elsif url =~ %r'^\w+://'
      raise "Invalid URL #{url.inspect} in #{__method__}: URL scheme should be 'https://', not '#{$~}'"
    else
      url = "https://#{url}"
    end

    # should we support `Firebase.url = 'myapp/path/to/child/'` ?  I'm gonna say
    # NO for now...
    unless url.include?('.firebaseio.com/') || url.include?('.firebaseio-demo.com/')
      after_scheme = url.index('//') + 2
      if url[after_scheme..-1].include?('/')
        raise "Invalid URL #{url.inspect} in #{__method__}: URL does not include 'firebaseio.com'"
      end
      url = "#{url}.firebaseio.com/"
    end

    @url = url
  end

  def self.url
    @url
  end

  def self.new(url=nil)
    if url.nil?
      @shared ||= alloc.initWithUrl(@url)
    elsif url
      alloc.initWithUrl(url)
    else
      super
    end
  end

  # @example
  #     Firebase.dispatch_queue(queue)
  #     # => Firebase.setDispatchQueue(queue)
  def self.dispatch_queue=(queue)
    if queue.is_a?(Dispatch::Queue)
      queue = queue.dispatch_object
    end
    setDispatchQueue(queue)
  end

  def connected_state(&block)
    connected?
  end

  def self.connected?(&block)
    Firebase.new.connected?(&block)
  end
  def connected?(&block)
    if block
      connected_state.on(:value) do |snapshot|
        block.call(snapshot.value?)
      end
    else
      self.root['.info/connected']
    end
  end

  def self.offline!
    Firebase.new.offline!
  end
  def offline!
    self.goOffline
  end

  def self.online!
    Firebase.new.online!
  end
  def online!
    self.goOnline
  end

  def transaction(options={}, &transaction)
    transaction = transaction || options[:transaction]
    completion_block = options[:completion]
    with_local_events = options[:local]
    if with_local_events.nil?
      if block_given?
        runTransactionBlock(transaction, andCompletionBlock: completion_block)
      else
        runTransactionBlock(transaction)
      end
    else
      if block_given?
        runTransactionBlock(transaction, andCompletionBlock: completion_block, withLocalEvents: with_local_events)
      else
        runTransactionBlock(transaction, withLocalEvents: with_local_events)
      end
    end
  end

  # @example
  #     firebase = Firebase.new('http://..../')
  #     firebase[]  # => childByAutoId
  #     firebase['fred']  # => childByAppendingPath('fred')
  #     firebase['fred', 'name', 'first']  # => childByAppendingPath('fred/name/first')
  #     firebase['fred']['name']['first']
  #     # => childByAppendingPath('fred').childByAppendingPath('name').childByAppendingPath('first'),
  #     # same as => childByAppendingPath('fred/name/first')
  def [](*names)
    if names.length == 0
      childByAutoId
    else
      childByAppendingPath(names.join('/'))
    end
  end

  def child(name)
    childByAppendingPath(name)
  end

  def []=(key, value)
    childByAppendingPath(key).set(value)
  end

  def clear!(&and_then)
    if block_given?
      removeValueWithCompletionBlock(and_then)
    else
      removeValue
    end
    return self
  end

  def <<(value)
    ref = childByAutoId
    ref.set(value)
    return ref
  end

  def push(value, &and_then)
    ref = childByAutoId
    ref.set(value, &and_then)
    return ref
  end

  def value=(value)
    setValue(value)
  end

  def set(value, &and_then)
    if block_given?
      setValue(value, withCompletionBlock: and_then)
    else
      setValue(value)
    end
    return self
  end

  def priority=(value)
    priority(value)
  end

  def priority(value, &and_then)
    if block_given?
      setPriority(value, withCompletionBlock: and_then)
    else
      setPriority(value)
    end
    return self
  end

  def set(value, priority: priority, &and_then)
    if block_given?
      setValue(value, andPriority: priority, withCompletionBlock: and_then)
    else
      setValue(value, andPriority: priority)
    end
    return self
  end

  def update(values, &and_then)
    if block_given?
      updateChildValues(values, withCompletionBlock: and_then)
    else
      updateChildValues(values)
    end
    return self
  end

  def cancel_disconnect(&and_then)
    if block_given?
      cancelDisconnectOperationsWithCompletionBlock(and_then)
    else
      cancelDisconnectOperations
    end
    return self
  end

  def remove_on_disconnect(&and_then)
    on_disconnect(nil, &and_then)
  end

  def on_disconnect(value, &and_then)
    if block_given?
      if value.nil?
        onDisconnectRemoveValueWithCompletionBlock(and_then)
      elsif NSDictionary === value
        onDisconnectUpdateChildValues(value, withCompletionBlock: and_then)
      else
        onDisconnectSetValue(value, withCompletionBlock: and_then)
      end
    else
      if value.nil?
        onDisconnectRemoveValue
      elsif NSDictionary === value
        onDisconnectUpdateChildValues(value)
      else
        onDisconnectSetValue(value)
      end
    end
    return self
  end

  def on_disconnect(value, priority: priority, &and_then)
    if block_given?
      onDisconnectSetValue(value, andPriority: priority, withCompletionBlock: and_then)
    else
      onDisconnectSetValue(value, andPriority: priority)
    end
    return self
  end

  def to_s
    description
  end

  def inspect
    "#<#{self.class}:0x#{self.object_id.to_s(16)}>"
  end

end
