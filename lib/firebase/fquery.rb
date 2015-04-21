class FQuery

  # previously the 'key' method was called 'name'
  def name
    self.key
  end

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

  def start_at(priority)
    queryStartingAtPriority(priority)
  end

  def start_at(priority, child: child)
    queryStartingAtPriority(priority, andChildName: child)
  end

  def equal_to(priority)
    queryEqualToPriority(priority)
  end

  def equal_to(priority, child: child)
    queryEqualToPriority(priority, andChildName: child)
  end

  def end_at(priority)
    queryEndingAtPriority(priority)
  end

  def end_at(priority, child: child)
    queryEndingAtPriority(priority, andChildName: child)
  end

  def limit(limit)
    queryLimitedToNumberOfChildren(limit)
  end

  def query(options={}, &block)
    fb_query = self

    if options[:order_by_key]
      fb_query = fb_query.queryOrderedByKey
    end

    if options[:order_by_priority]
      fb_query = fb_query.queryOrderedByPriority
    end

    if options[:order_by]
      fb_query = fb_query.queryOrderedByChild(options[:order_by])
    end

    if options[:first]
      fb_query = fb_query.queryLimitedToFirst(options[:first])
    end

    if options[:last]
      fb_query = fb_query.queryLimitedToLast(options[:last])
    end

    if options[:starting_at] && options[:key]
      fb_query = fb_query.queryStartingAtValue(options[:starting_at], childKey: options[:key])
    elsif options[:starting_at]
      fb_query = fb_query.queryStartingAtValue(options[:starting_at])
    end

    if options[:ending_at] && options[:key]
      fb_query = fb_query.queryEndingAtValue(options[:ending_at], childKey: options[:key])
    elsif options[:ending_at]
      fb_query = fb_query.queryEndingAtValue(options[:ending_at])
    end

    if options[:equal_to] && options[:key]
      fb_query = fb_query.queryEqualToValue(options[:equal_to], childKey: options[:key])
    elsif options[:equal_to]
      fb_query = fb_query.queryEqualToValue(options[:equal_to])
    end

    if block
      event_type = options.fetch(:on, FEventTypeValue)
      event_type = Firebase.convert_event_type(event_type)
      return fb_query.observeEventType(event_type, withBlock: and_then)
    else
      fb_query
    end
  end

end
