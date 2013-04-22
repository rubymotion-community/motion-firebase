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

    Firebase.new(url)

##### Getting references to children locations

    firebase[path]
    firebase[]  # childByAutoId
    firebase['fred']  # childByAppendingPath('fred')

##### Writing data

    firebase << {'key': 'value'}
    # => firebase.childByAutoId.updateChildValues(values), returns the new child

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

    firebase.update(values)
    firebase.update(values) { |error| 'completion block' }

##### Attaching observers to read data

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

##### Detaching observers

    firebase.off
    firebase.off(handle)

##### Querying and limiting

    # these are not wrapped at the moment, because I don't completely understand
    # what they do.
    # firebase.queryStartingAtPriority()
    # firebase.queryStartingAtPriority(andChildName:)
    # firebase.queryEndingAtPriority()
    # firebase.queryEndingAtPriority(andChildName:)
    # firebase.queryLimitedToNumberOfChildren()

##### Managing presence

    firebase.on_disconnect(value)
    firebase.on_disconnect(value) { |error| 'completion block' }
    firebase.on_disconnect(value, priority:priority)
    firebase.on_disconnect(value, priority:priority) { |error| 'completion block' }
    firebase.on_disconnect(nil)
    firebase.on_disconnect(nil) { |error| 'completion block' }
    firebase.on_disconnect({ child: values })
    firebase.on_disconnect({ child: values }) { |error| 'completion block' }
    firebase.cancel_disconnect
    firebase.cancel_disconnect { |error| 'completion block' }

##### Authenticating

    firebase.auth(credential)
    firebase.auth(credential) { |error, data| 'completion block' }
    firebase.auth(credential,
      completion: proc { |error, data| 'completion block' },
      disconnect: proc { |error| 'completion block', },
      )
    firebase.unauth
    # when using FirebaseAuthClient to authenticate, this child node should be
    # monitored for changes
    firebase.auth_state
    # usually you'll want to monitor its value, so this is a helper for that:
    handle = firebase.on_auth do |snapshot|
    end
    # be a good citizen and turn off the listener later!
    firebase.off(handle)

##### Transactions

    firebase.run { |data| 'transaction block' }
    firebase.run(
      transaction: proc { |data| 'transaction block' },
      completion: proc { |error, committed, snapshot| }
      )
    firebase.run(
      transaction: proc { |data| 'transaction block' },
      completion: proc { |error, committed, snapshot| }
      local: true || false,
      )

##### Retrieving String Representation

    firebase.to_s
    firebase.inspect

##### Properties

    firebase.parent
    firebase.root
    firebase.name

##### Global configuration and settings

    Firebase.dispatch_queue=(queue)
    Firebase.sdkVersion


# FirebaseAuthClient Class Reference

##### Initializing a FirebaseAuthClient instance

    ref = Firebase.new(url)
    auth = FirebaseAuthClient.new(ref)

##### Checking current authentication status

    auth.check { |error, user| }

##### Removing any existing authentication

    auth.logout

##### Email/password authentication methods

`credentials` for `create,remove,login` should include `:email` and `:password`.
For `update`, `credentials` should include `:email`, `:old_password` and
`:new_password`.

    auth.create(email: 'hello@example.com', password: '12345') { |error, user| }
    auth.remove(email: 'hello@example.com', password: '12345') { |error, user| }
    auth.login(email: 'hello@example.com', password: '12345') { |error, user| }
    auth.update(email: 'hello@example.com', old_password: '12345', new_password: '54321') { |error, success| }

##### Facebook authentication methods

`credentials` should include `:app_id` and `:permissions`

    auth.login_to_facebook(app_id: '123abc', permissions: ['email']) { |error, user| }

##### Twitter authentication methdos

`credentials` should include `:app_id` and `:on_multiple` block. The
`:on_multiple` block is called when more than one account is found.  It is
passed an array of usernames and should return an index or `NSNotFound`.

    auth.login_to_twitter(app_id: '123abc', on_multiple: ->(usernames) { return 0 }) { |error, user| }

##### Global configuration and settings

    FirebaseAuthClient.sdkVersion

##### Retrieving String Representation

    firebase.to_s
    firebase.inspect
