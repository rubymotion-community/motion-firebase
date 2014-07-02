motion-firebase
--------

A RubyMotion wrapper for the Firebase SDK.

Adds more rubyesque methods to the built-in classes.

For a Ruby (MRI) Firebase wrapper, check out <https://github.com/derailed/bigbertha>.

Versioning
-------

versioning matches Firebase's SDK major and minor version numbers, but revision
numbers could be different.

SDK
---

# Firebase Class Reference

##### Initializing a Firebase object

```ruby
    Firebase.new(url)
```

##### Getting references to children locations

```ruby
    firebase[path]
    firebase[]  # childByAutoId
    firebase['fred']  # childByAppendingPath('fred')
```

##### Writing data

```ruby
    firebase << { key: 'value' }
    # => firebase.childByAutoId.setValue({ key: 'value'}), returns the new child

    # Since firebase works with simple objects, this is equivalent to
    # => firebase.childByAutoId.setValue({ 'key' => 'value'})

    # set value
    firebase.value = value
    firebase.set(value)
    firebase.set(value) { 'completion block' }
    firebase.set(value, priority: priority)
    firebase.set(value, priority: priority) { 'completion block' }

    # set value of child node
    firebase['first_name'] = 'fred'  # childByAppendingPath('fred').set('fred')

    # remove value
    firebase.clear!
    firebase.clear! { 'completion block' }

    # priority
    firebase.priority = priority
    firebase.priority(priority)
    firebase.priority(priority) { |error| 'completion block' }

    # "updating" is used to update some children, but leaving others unchanged.
    # (set, on the other hand, replaces the value entirely, so using set with a
    # hash will remove keys that weren't specified in the new hash)
    firebase.set({ first_name: 'motion', last_name: 'fireball' })
    firebase.update(last_name: 'firebase')  # only updates last_name, first_name is left unchanged
    firebase.update(last_name: 'firebase') { |error| 'completion block' }
    # for comparison:
    firebase.set(last_name: 'firebase')  # first_name is now 'nil'
```

##### Attaching observers to read data

```ruby
    handle = firebase.on(event_type) { |snapshot| 'completion block' }
    handle = firebase.on(event_type) { |snapshot, previous_sibling_name| 'completion block' }
    handle = firebase.on(event_type,
      completion: proc { |snapshot, previous_sibling_name| 'completion block' },
      disconnect: proc { 'completion block' }
      )
    handle = firebase.once(event_type) { |snapshot| 'completion block' }
    handle = firebase.once(event_type) { |snapshot, previous_sibling_name| 'completion block' }
    handle = firebase.once(event_type,
      completion: proc { |snapshot, previous_sibling_name| 'completion block' },
      disconnect: proc { 'completion block' }
      )
```

##### Detaching observers

```ruby
    firebase.off
    # => firebase.removeAllObservers

    firebase.off(handle)
    # => firebase.removeObserverWithHandle(handle)
```

##### Priority and Limiting
###### similar-to-yet-different-than "ORDER BY" and "LIMIT"

```ruby
    firebase.start_at(priority)
    # => firebase.queryStartingAtPriority(priority)

    firebase.start_at(priority, child: child_name)
    # => firebase.queryStartingAtPriority(priority, andChildName: child_name)

    firebase.end_at(priority)
    # => firebase.queryEndingAtPriority(priority)

    firebase.end_at(priority, child: child_name)
    # => firebase.queryEndingAtPriority(priority, andChildName: child_name)

    firebase.limit(limit)
    # => firebase.queryLimitedToNumberOfChildren(limit)
```

##### Managing presence

```ruby
    firebase.online!
    firebase.offline!
    firebase.connected_state  # returns a Firebase ref that changes value depending on connectivity
    firebase.on_disconnect(value)  # set the ref to `value` when disconnected
    firebase.on_disconnect(value) { |error| 'completion block' }
    firebase.on_disconnect(value, priority: priority)
    firebase.on_disconnect(value, priority: priority) { |error| 'completion block' }
    firebase.on_disconnect(nil)
    firebase.on_disconnect(nil) { |error| 'completion block' }
    firebase.on_disconnect({ child: values })
    firebase.on_disconnect({ child: values }) { |error| 'completion block' }
    firebase.cancel_disconnect
    firebase.cancel_disconnect { |error| 'completion block' }
```

##### Authenticating

```ruby
    firebase.auth(secret_key)
    firebase.auth(secret_key) { |error, data| 'completion block' }
    firebase.auth(secret_key,
      completion: proc { |error, data| 'completion block' },
      disconnect: proc { |error| 'completion block', },
      )
    # calls `unauth`, or if you pass a block calls `unauthWithCompletionBlock`
    firebase.unauth
    firebase.unauth do |error|
      # ...
    end
    # when using FirebaseSimpleLogin to authenticate, this child node should be
    # monitored for changes
    firebase.auth_state
    # usually you'll want to monitor its value, so this is a helper for that:
    handle = firebase.on_auth do |snapshot|
    end
    # be a good citizen and turn off the listener later!
    firebase.off(handle)
```

##### Transactions

```ruby
    firebase.transaction do |data|
      current_value = data.value
      current_value += 1
      FTransactionResult.successWithValue(current_value)
    end
    firebase.transaction(local: false) do |data|
      #...
    end
    firebase.transaction(
      completion: proc { |error, committed, snapshot| }
      ) do |data|
      current_value = data.value
      current_value += 1
      FTransactionResult.successWithValue(current_value)
    end
    firebase.transaction(
      transaction: proc { |data| 'transaction block' },
      completion: proc { |error, committed, snapshot| }
      local: true || false,
      )
```

##### Retrieving String Representation

```ruby
    firebase.to_s
    firebase.inspect
```

##### Properties

```ruby
    firebase.parent
    firebase.root
    firebase.name
```

##### Global configuration and settings

```ruby
    Firebase.dispatch_queue=(queue)
    Firebase.sdkVersion
```

# FirebaseSimpleLogin Class Reference

    require 'motion-firebase-auth'

##### Initializing a FirebaseSimpleLogin instance

```ruby
    ref = Firebase.new(url)
    auth = FirebaseSimpleLogin.new(ref)
```

##### Checking current authentication status

```ruby
    auth.check { |error, user| }
```

##### Removing any existing authentication

```ruby
    auth.logout
```

##### Email/password authentication methods

`credentials` for `create,remove,login` should include `:email` and `:password`.
For `update`, `credentials` should include `:email`, `:old_password` and
`:new_password`.

```ruby
    auth.create(email: 'hello@example.com', password: '12345') { |error, user| }
    auth.remove(email: 'hello@example.com', password: '12345') { |error, user| }
    auth.login(email: 'hello@example.com', password: '12345') { |error, user| }
    auth.update(email: 'hello@example.com', old_password: '12345', new_password: '54321') { |error, success| }
```

##### Facebook authentication methods

`credentials` must include `:app_id`. `:permissions` defaults to `['email']` and
`:audience` defaults to `ACFacebookAudienceOnlyMe`.

```ruby
    auth.login_to_facebook(app_id: '123abc') { |error, user| }
```

##### Twitter authentication methods

`credentials` should include `:app_id` and `:on_multiple` block. The
`:on_multiple` block is called when more than one account is found.  It is
passed an array of usernames and should return an index or `NSNotFound`.

```ruby
    auth.login_to_twitter(app_id: '123abc', on_multiple: ->(usernames) { return 0 }) { |error, user| }
```

##### Global configuration and settings

```ruby
    FirebaseSimpleLogin.sdkVersion
```

##### Retrieving String Representation

```ruby
    firebase.to_s
    firebase.inspect
```
