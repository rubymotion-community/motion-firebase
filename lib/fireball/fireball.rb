class Fireball < Firebase

  def self.new(url)
    alloc.initWithUrl(url)
  end

  # @example
  #     Fireball.dispatch_queue(queue)
  #     # => Firebase.setDispatchQueue(queue)
  def self.dispatch_queue=(queue)
    setDispatchQueue(queue)
  end

  # @example
  #     fireball = Fireball.new('http://..../')
  #     fireball.auth('secretkey', then: ->{}, disconnect:{})
  #     # => firebase.authWithCredential(credential)
  def auth(credential, options={}, &handler)
    handler = handler || options[:completion]
    disconnect_block = options[:disconnect]
    authWithCredential(credential, withCompletionBlock:handler, withCancelBlock:disconnect_block)
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
  #     fireball = Fireball.new('http://..../')
  #     fireball[]  # => childByAutoId
  #     fireball['fred']  # => childByAppendingPath('fred')
  #     fireball['fred', 'name', 'first']  # => childByAppendingPath('fred/name/first')
  #     fireball['fred']['name']['first']
  #     # => childByAppendingPath('fred').childByAppendingPath('name').childByAppendingPath('first'),
  #     # same as => childByAppendingPath('fred/name/first')
  def [](*names)
    if names.length == 0
      childByAutoId
    else
      childByAppendingPath(name.join('/'))
    end
  end

  def clear!(&and_then)
    if and_then
      removeValueWithCompletionBlock(and_then)
    else
      removeValue
    end
  end

  def <<(value)
    setValue(value)
  end

  def priority(value, &and_then)
    if and_then
      setPriority(value, withCompletionBlock:and_then)
    else
      setPriority(value)
    end
  end

  def value(value, priority:priority, &and_then)
    if and_then
      setValue(value, andPriority:priority, withCompletionBlock:and_then)
    else
      setValue(value, andPriority:priority)
    end
  end

  def value(value, &and_then)
    if and_then
      setValue(value, withCompletionBlock:and_then)
    else
      setValue(value)
    end
  end

  def on(event_type, options={}, &handler)
    handler = handler || options[:completion]
    raise "event handler is required" unless handler
    raise "event handler must accept one or two arguments" unless handler.arity == 1 || handler.arity == 2

    event_type = _convert_event_type(event_type)
    disconnect_block = options[:disconnect]
    raise ":disconnect handler must not accept any arguments" if disconnect_block && disconnect_block.arity > 0

    if handler.arity == 1
      if disconnect_block
        observeEventType(FEventTypeChildAdded, withBlock:handler, withCancelBlock:disconnect_block)
      else
        observeEventType(FEventTypeChildAdded, withBlock:handler)
      end
    else
      if disconnect_block
        observeEventType(FEventTypeChildAdded, andPreviousSiblingNameWithBlock:handler, withCancelBlock:disconnect_block)
      else
        observeEventType(FEventTypeChildAdded, andPreviousSiblingNameWithBlock:handler)
      end
    end
  end

  def once(event_type, options={}, &handler)
    handler = handler || options[:completion]
    raise "event handler is required" unless handler
    raise "event handler must accept one or two arguments" unless handler.arity == 1 || handler.arity == 2

    event_type = _convert_event_type(event_type)
    disconnect_block = options[:disconnect]
    raise ":disconnect handler must not accept any arguments" if disconnect_block && disconnect_block.arity > 0

    if handler.arity == 1
      if disconnect_block
        observeSingleEventType(FEventTypeChildAdded, withBlock:handler, withCancelBlock:disconnect_block)
      else
        observeSingleEventType(FEventTypeChildAdded, withBlock:handler)
      end
    else
      if disconnect_block
        observeSingleEventType(FEventTypeChildAdded, andPreviousSiblingNameWithBlock:handler, withCancelBlock:disconnect_block)
      else
        observeSingleEventType(FEventTypeChildAdded, andPreviousSiblingNameWithBlock:handler)
      end
    end
  end

  def off(handle=nil)
    if handle
      removeObserverWithHandle(handle)
    else
      removeAllObservers
    end
  end

  def cancel_disconnect(&handler)
    if handler
      cancelDisconnectOperationsWithCompletionBlock(handler)
    else
      cancelDisconnectOperations
    end
  end

  def on_disconnect(value, &handler)
    if handler
      if value.nil?
        onDisconnectRemoveValueWithCompletionBlock(handler)
      elsif NSDictionary === value
        onDisconnectUpdateChildValues(value, withCompletionBlock:handler)
      else
        onDisconnectSetValue(value, withCompletionBlock:handler)
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
  end

  def on_disconnect(value, priority:priority, &handler)
    if handler
      onDisconnectSetValue(value, andPriority:priority, withCompletionBlock:handler)
    else
      onDisconnectSetValue(value, andPriority:priority)
    end
  end

private
  def _convert_event_type(event_type)
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
    end
    return event_type
  end

end
