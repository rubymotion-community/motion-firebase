class Firebase

  def self.new(url)
    alloc.initWithUrl(url)
  end

  # @example
  #     Firebase.dispatch_queue(queue)
  #     # => Firebase.setDispatchQueue(queue)
  def self.dispatch_queue=(queue)
    setDispatchQueue(queue)
  end

  # @example
  #     firebase = Firebase.new('http://..../')
  #     firebase.auth('secretkey', then: ->{}, disconnect:{})
  #     # => firebase.authWithCredential(credential)
  def auth(credential, options={}, &and_then)
    and_then = and_then || options[:completion]
    disconnect_block = options[:disconnect]
    authWithCredential(credential, withCompletionBlock:and_then, withCancelBlock:disconnect_block)
    return self
  end

  def auth_state
    self.root[".info/authenticated"]
  end

  def run(options={}, &transaction)
    transaction = transaction || options[:transaction]
    completion_block = options[:completion]
    with_local_events = options[:local]
    if with_local_events.nil?
      if completion_block
        runTransactionBlock(transaction, andCompletionBlock:completion_block)
      else
        runTransactionBlock(transaction)
      end
    else
      runTransactionBlock(transaction, andCompletionBlock:completion_block, withLocalEvents:with_local_events)
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

  def []=(key, value)
    childByAppendingPath(key).set(value)
  end

  def clear!(&and_then)
    if and_then
      removeValueWithCompletionBlock(and_then)
    else
      removeValue
    end
    return self
  end

  def <<(value)
    ref = childByAutoId
    ref.update(value)
    return ref
  end

  def value=(value)
    setValue(value)
  end

  def set(value, &and_then)
    if and_then
      setValue(value, withCompletionBlock:and_then)
    else
      setValue(value)
    end
    return self
  end

  def priority=(value)
    priority(value)
  end

  def priority(value, &and_then)
    if and_then
      setPriority(value, withCompletionBlock:and_then)
    else
      setPriority(value)
    end
    return self
  end

  def set(value, priority:priority, &and_then)
    if and_then
      setValue(value, andPriority:priority, withCompletionBlock:and_then)
    else
      setValue(value, andPriority:priority)
    end
    return self
  end

  def update(values, &and_then)
    if and_then
      updateChildValues(values, withCompletionBlock:and_then)
    else
      updateChildValues(values)
    end
    return self
  end

  def on(event_type, options={}, &and_then)
    and_then = and_then || options[:completion]
    raise "event handler is required" unless and_then
    raise "event handler must accept one or two arguments" unless and_then.arity == 1 || and_then.arity == 2

    event_type = Firebase._convert_event_type(event_type)
    disconnect_block = options[:disconnect]
    raise ":disconnect handler must not accept any arguments" if disconnect_block && disconnect_block.arity > 0

    if and_then.arity == 1
      if disconnect_block
        observeEventType(event_type, withBlock:and_then, withCancelBlock:disconnect_block)
      else
        observeEventType(event_type, withBlock:and_then)
      end
    else
      if disconnect_block
        observeEventType(event_type, andPreviousSiblingNameWithBlock:and_then, withCancelBlock:disconnect_block)
      else
        observeEventType(event_type, andPreviousSiblingNameWithBlock:and_then)
      end
    end
  end

  def once(event_type, options={}, &and_then)
    and_then = and_then || options[:completion]
    raise "event handler is required" unless and_then
    raise "event handler must accept one or two arguments" unless and_then.arity == 1 || and_then.arity == 2

    event_type = Firebase._convert_event_type(event_type)
    disconnect_block = options[:disconnect]
    raise ":disconnect handler must not accept any arguments" if disconnect_block && disconnect_block.arity > 0

    if and_then.arity == 1
      if disconnect_block
        observeSingleEventOfType(event_type, withBlock:and_then, withCancelBlock:disconnect_block)
      else
        observeSingleEventOfType(event_type, withBlock:and_then)
      end
    else
      if disconnect_block
        observeSingleEventOfType(event_type, andPreviousSiblingNameWithBlock:and_then, withCancelBlock:disconnect_block)
      else
        observeSingleEventOfType(event_type, andPreviousSiblingNameWithBlock:and_then)
      end
    end
  end

  def off(handle=nil)
    if handle
      removeObserverWithHandle(handle)
    else
      removeAllObservers
    end
    return self
  end

  def cancel_disconnect(&and_then)
    if and_then
      cancelDisconnectOperationsWithCompletionBlock(and_then)
    else
      cancelDisconnectOperations
    end
    return self
  end

  def on_disconnect(value, &and_then)
    if and_then
      if value.nil?
        onDisconnectRemoveValueWithCompletionBlock(and_then)
      elsif NSDictionary === value
        onDisconnectUpdateChildValues(value, withCompletionBlock:and_then)
      else
        onDisconnectSetValue(value, withCompletionBlock:and_then)
      end
    else
      if value == :remove
        onDisconnectRemoveValue
      elsif NSDictionary === value
        onDisconnectUpdateChildValues(value)
      else
        onDisconnectSetValue(value)
      end
    end
    return self
  end

  def on_disconnect(value, priority:priority, &and_then)
    if and_then
      onDisconnectSetValue(value, andPriority:priority, withCompletionBlock:and_then)
    else
      onDisconnectSetValue(value, andPriority:priority)
    end
    return self
  end

  def inspect
    "#<#{self.class}:0x#{self.object_id.to_s(16)}>"
  end

private
  def self._convert_event_type(event_type)
    case event_type
    when :child_added, :added
      return FEventTypeChildAdded
    when :child_moved, :moved
      FEventTypeChildMoved
    when :child_changed, :changed
      return FEventTypeChildChanged
    when :child_removed, :removed
      return FEventTypeChildRemoved
    when :value
      return FEventTypeValue
    else
      NSLog("Unknown event type #{event_type.inspect}")
    end
    return event_type
  end

end
