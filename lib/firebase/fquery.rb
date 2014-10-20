class FQuery

  def on(event_type, options={}, &and_then)
    and_then = and_then || options[:completion]
    raise "event handler is required" unless and_then
    raise "event handler must accept one or two arguments" unless and_then.arity == 1 || and_then.arity == 2

    event_type = Firebase.convert_event_type(event_type)
    disconnect_block = options[:disconnect]
    raise ":disconnect handler must not accept any arguments" if disconnect_block && disconnect_block.arity > 0

    if and_then.arity == 1
      if disconnect_block
        return observeEventType(event_type, withBlock:and_then, withCancelBlock:disconnect_block)
      else
        return observeEventType(event_type, withBlock:and_then)
      end
    else
      if disconnect_block
        return observeEventType(event_type, andPreviousSiblingNameWithBlock:and_then, withCancelBlock:disconnect_block)
      else
        return observeEventType(event_type, andPreviousSiblingNameWithBlock:and_then)
      end
    end
  end

  def once(event_type, options={}, &and_then)
    and_then = and_then || options[:completion]
    raise "event handler is required" unless and_then
    raise "event handler must accept one or two arguments" unless and_then.arity == 1 || and_then.arity == 2

    event_type = Firebase.convert_event_type(event_type)
    disconnect_block = options[:disconnect]
    raise ":disconnect handler must not accept any arguments" if disconnect_block && disconnect_block.arity > 0

    if and_then.arity == 1
      if disconnect_block
        return observeSingleEventOfType(event_type, withBlock:and_then, withCancelBlock:disconnect_block)
      else
        return observeSingleEventOfType(event_type, withBlock:and_then)
      end
    else
      if disconnect_block
        return observeSingleEventOfType(event_type, andPreviousSiblingNameWithBlock:and_then, withCancelBlock:disconnect_block)
      else
        return observeSingleEventOfType(event_type, andPreviousSiblingNameWithBlock:and_then)
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

  def start_at(priority=nil)
    queryStartingAtPriority(priority)
  end

  def start_at(priority=nil, child:child)
    queryStartingAtPriority(priority, andChildName:child)
  end

  def end_at(priority=nil)
    queryEndingAtPriority(priority)
  end

  def end_at(priority=nil, child:child)
    queryEndingAtPriority(priority, andChildName:child)
  end

  def limit(limit)
    queryLimitedToNumberOfChildren(limit)
  end
end
