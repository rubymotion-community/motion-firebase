class FIRDatabaseReference

  def connected_state(&block)
    connected?
  end

  def self.connected?(&block)
    self.connected?(&block)
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



  # Data handling

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

  def []=(key, value)
    child(key).set(value)
  end

  def <<(value)
    ref = childByAutoId
    ref.set(value)
    return ref
  end

  def push(value, &and_then)
    ref = self.childByAutoId
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

  def clear!(&and_then)
    if block_given?
      removeValueWithCompletionBlock(and_then)
    else
      removeValue
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