motion-firebase
--------

A RubyMotion wrapper for the Firebase SDK.

Adds more rubyesque methods to the built-in classes.

For a Ruby (MRI) Firebase wrapper, check out <https://github.com/derailed/bigbertha>.

Installation
============

The **motion-firebase** gem ships with "freeze dried" copies of the Firebase
framework.  This way we can guarantee that the version of **motion-firebase** is
*definitely* compatible with the version of Firebase that is included.  As new
features get announced, we update the gem.

Also, it means that installation is easy!  When you compile your RubyMotion
project, the Firebase SDK gets included automatically.

motion-firebase 3.0
========

Lots of changes in this version: <3.0.md>

# SDK

##### Initializing a Firebase object

```ruby
Firebase.new(url)

# it's common to set a global firebase URL.  Set it in your app delegate,
# and calling `new` will use that default URL.
Firebase.url = 'https://your-app.firebaseio.com'
Firebase.url  # => 'https://your-app.firebaseio.com'
Firebase.new

# these all work, too:
Firebase.url = 'your-app.firebaseio.com'
Firebase.url = 'your-app'
Firebase.url  # => 'https://your-app.firebaseio.com'
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

[Events](https://www.firebase.com/docs/web/guide/retrieving-data.html) can have the value of:

```ruby
:child_added, :added, FEventTypeChildAdded
:child_moved, :moved, FEventTypeChildMoved
:child_changed, :changed, FEventTypeChildChanged
:child_removed, :removed, FEventTypeChildRemoved
:value, FEventTypeValue
```

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

firebase.equal_to(priority)
# => firebase.queryEqualToPriority(priority)

firebase.equal_to(priority, child: child_name)
# => firebase.queryEqualToPriority(priority, andChildName: child_name)

firebase.end_at(priority)
# => firebase.queryEndingAtPriority(priority)

firebase.end_at(priority, child: child_name)
# => firebase.queryEndingAtPriority(priority, andChildName: child_name)

firebase.limit(limit)
# => firebase.queryLimitedToNumberOfChildren(limit)
```

##### Managing presence

SOO COOL!  Play with these, you can *easily* create a presence system for your
real-time app or game.

```ruby
Firebase.online!
Firebase.offline!
Firebase.connected?  # returns a Firebase ref that changes value depending on connectivity

# or you can pass in a block, this block will be called with the connected
# state as a bool:
handler = Firebase.connected? do |connected|
  if connected
    # so awesome
  end
end
# you should turn it off when you're done, otherwise you'll have a memory leak
Firebase.off(handler)

# so what you do is get a ref to the authenticated user's "presence" value.
# Then, on_disconnect, set the value to 'false'.
firebase.on_disconnect(value)  # set the ref to `value` when disconnected
firebase.on_disconnect(value) { |error| 'completion block' }
firebase.on_disconnect(value, priority: priority)
firebase.on_disconnect(value, priority: priority) { |error| 'completion block' }
firebase.on_disconnect(nil)
firebase.on_disconnect(nil) { |error| 'completion block' }
firebase.on_disconnect({ child: values })
firebase.on_disconnect({ child: values }) { |error| 'completion block' }

# sometimes you need to cancel these 'on_disconnect' operations
firebase.cancel_disconnect
firebase.cancel_disconnect { |error| 'completion block' }
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
Motion::Firebase::SdkVersion  # this string is more human readable than sdkVersion
```


# Firebase Authentication Reference

Most of the authentication methods can be called statically as long as you have
set a default `Firebase.url`

##### Checking current authentication status

```ruby
Firebase.authenticated?  # => true/false
# you pretty much always need to hold a reference to the "handler"
auth_handler = Firebase.authenticated? do |auth_data|
  if auth_data
    # authenticated!
  else
    # not so much
  end
end
# turn off the handler, otherwise, yeah, memory leaks.
Firebase.off_auth(auth_handler)
```

##### Authenticate with previous token

```ruby
Firebase.auth(token) do |error, auth_data|
end
```

##### Removing any existing authentication

```ruby
Firebase.logout
```

## Email/password authentication methods

This is the most common way to login.  It allows Firebase to create users and
tokens.

```ruby
Firebase.create_user(email: 'hello@example.com', password: '12345') { |error, auth_data| }
Firebase.remove_user(email: 'hello@example.com', password: '12345') { |error, auth_data| }
Firebase.login(email: 'hello@example.com', password: '12345') { |error, auth_data| }
Firebase.login_anonymously { |error, auth_data| }
Firebase.update_user(email: 'hello@example.com', old_password: '12345', new_password: '54321') { |error, success| }

auth_data.uid # is a globally unique user identifier
auth_data.token # can be stored (in a keychain!) to authenticate the same user again later
```

See <https://www.firebase.com/docs/ios/api/#fauthdata_properties> for other
`auth_data` properties.


## Other authentication providers

##### Facebook authentication

This Facebook helper is a port of the Objective-C code from
<https://www.firebase.com/docs/ios/guide/login/facebook.html>.

```ruby
Firebase.open_facebook_session(
    permissions: ['public_profile'],  # these are the default values.  if
    allow_login_ui: true,             # you're OK with them, they are
    ) do |error, auth_data|           # optional, so just provide a block.
end
```

##### Twitter authentication

This Twitter helper is a port of the Objective-C code from
<https://www.firebase.com/docs/ios/guide/login/twitter.html>.  You should read
that page to see how Firebase recommends handling multiple accounts.  It's a
little streamlined here, since `open_twitter_session` returns a block that you
can call with the chosen account.

```ruby
# it's nice to be able to set-and-forget the twitter_api_key (in your
# application delegate, for example)
Firebase.twitter_api_key = 'your key!'

# You must set Firebase.url=, or call open_twitter_session on an existing
# Firebase ref.  The first step is to get the Twitter accounts on this
# device.  Even if there is just one, you need to "choose" it here. Also,
# you can pass the twitter api_key as an option, otherwise this method will
# use Firebase.twitter_api_key
Firebase.open_twitter_session(api_key: 'your key!') do |error, accounts, next_step|
  # next_step is a block you call with the chosen twitter account and a
  # firebase handler for the authentication success or failure
  if error
    # obviously do some stuff here
  else
    present_twitter_chooser(accounts, next_step) do |error, auth_data|
      # this block is passed to next_step in present_twitter_chooser
      if error
        # bummer
      else
        # awesome!
      end
    end
  else
end

def present_twitter_chooser(accounts, next_step, &firebase_handler)
  if accounts.length == 1
    next_step.call(accounts[0], &firebase_handler)
  else
    # present a controller or action sheet or something like that
    ... awesome twitter account chooser code ...
    next_step.call(account, &firebase_handler)
  end
end
```

##### Github authentication

Firebase doesn't provide much help on this one.  I'm not even sure *how* to get
a github access token from the user... but anyway here's the `motion-firebase`
code based on <https://www.firebase.com/docs/ios/guide/login/github.html>.

```ruby
Firebase.github_token = 'github oauth token'
Firebase.open_github_session do |error, auth_data|
end
```

##### Google authentication

This process is more involved, and relies on the GooglePlus framework.  I didn't
take the time to port the code this time, but I hope someone does someday! 😄

You can read Firebase's instructions here: <https://www.firebase.com/docs/ios/guide/login/google.html>

```ruby
Firebase.google_token = 'google oauth token'
Firebase.open_google_session do |error, auth_data|
end
```

##### Generic OAuth Authentication

Usually you will use the helpers from above, but here are some lower level
methods:

```ruby
# using a token
firebase_ref.login_to_oauth(provider, token: token) do |error, auth_data| .. end
firebase_ref.login_to_oauth(provider, token) do |error, auth_data| .. end

# using parameters
firebase_ref.login_to_oauth(provider, oauth_token: token, oauth_token_secret: secret) do |error, auth_data| .. end
params = { ... }
firebase_ref.login_to_oauth(provider, params) do |error, auth_data| .. end

# which is a wrapper for these SDK methods:
firebase_ref.authWithOAuthProvider(provider, token: token, withCompletionBlock: block)
firebase_ref.authWithOAuthProvider(provider, parameters: params, withCompletionBlock: block)

# Again, the `open_*_session` methods are even more convenient.
firebase_ref.login_to_facebook(facebook_access_token, &block)
firebase_ref.login_to_twitter(token: token, secret: secret, &block)
firebase_ref.login_to_github(github_oauth_token, &block)
firebase_ref.login_to_google(google_oauth_token, &block)
```
