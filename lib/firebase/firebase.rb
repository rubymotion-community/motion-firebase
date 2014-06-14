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
  #     firebase.auth('secretkey', completion: ->{}, disconnect:{})
  #     # => firebase.authWithCredential(credential)
  def auth(credential, options={}, &and_then)
    and_then = and_then || options[:completion]
    disconnect_block = options[:disconnect]
    authWithCredential(credential, withCompletionBlock: and_then, withCancelBlock: disconnect_block)
    return self
  end

  alias_method :old_unauth, :unauth

  def unauth(&block)
    if block_given?
      unauthWithCompletionBlock(block)
    else
      old_unauth
    end
  end

  def auth_state
    self.root['.info/authenticated']
  end

  def connected_state
    self.root['.info/connected']
  end

  def offline!
    goOffline
  end

  def online!
    goOnline
  end

  def run(options={}, &transaction)
    NSLog('The method ‘Firebase#run’ has been deprecated in favor of ‘Firebase#transaction’')
    self.transaction(options, &transaction)
  end

  def transaction(options={}, &transaction)
    transaction = transaction || options[:transaction]
    completion_block = options[:completion]
    with_local_events = options[:local]
    if with_local_events.nil?
      if completion_block
        runTransactionBlock(transaction, andCompletionBlock: completion_block)
      else
        runTransactionBlock(transaction)
      end
    else
      if completion_block
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
    if and_then
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
    if and_then
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
    if and_then
      setPriority(value, withCompletionBlock: and_then)
    else
      setPriority(value)
    end
    return self
  end

  def set(value, priority: priority, &and_then)
    if and_then
      setValue(value, andPriority: priority, withCompletionBlock: and_then)
    else
      setValue(value, andPriority: priority)
    end
    return self
  end

  def update(values, &and_then)
    if and_then
      updateChildValues(values, withCompletionBlock: and_then)
    else
      updateChildValues(values)
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

  # Calls the block when the value is true
  def on_auth(options={}, &block)
    auth_state.on(:value, options, &block)
  end

  def on_disconnect(value, &and_then)
    if and_then
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
    if and_then
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
