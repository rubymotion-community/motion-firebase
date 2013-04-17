fireball
--------

A RubyMotion wrapper for the Firebase SDK.

Just the main class `Firebase` is wrapped.

Versioning
-------

versioning matches Firebase's SDK major and minor version numbers, but revision
numbers could be different.

SDK
---

# Fireball Class Reference

**Inherits from** `Firebase : FQuery : NSObject`

## Overview

A `Fireball` reference represents a particular location in your Firebase and can
be used for reading or writing data to that Firebase location.

This class is the starting point for all Firebase operations. After you’ve
initialized it with `Fireball.new` you can use it to read data (ie. `on() {}`),
write data (ie. `[key]=`), and to create new Fireball references (ie. `[]`).

## Tasks

##### Initializing a Fireball object

    Fireball.new(url)

##### Getting references to children locations

    fireball[path]
    fireball[]  # childByAutoId
    fireball['fred']  # childByAppendingPath('fred')

##### Writing data

    fireball << {'key': 'value'}
    # => fireball.childByAutoId.updateChildValues(values), returns the new child

    # set value
    fireball.value = value
    fireball.set(value)
    fireball.set(value) { 'completion block' }
    fireball.set(value, priority: priority)
    fireball.set(value, priority: priority) { 'completion block' }

    # set value of child node
    fireball['first_name'] = 'fred'  # childByAppendingPath('fred').set('fred')

    # remove value
    fireball.clear!
    fireball.clear! { 'completion block' }

    # priority
    fireball.priority = priority
    fireball.priority(priority)
    fireball.priority(priority) { |error| 'completion block' }

    fireball.update(values)
    fireball.update(values) { |error| 'completion block' }

##### Attaching observers to read data

    handle = fireball.on(event_type) { |snapshot| 'completion block' }
    handle = fireball.on(event_type) { |snapshot, previous_sibling_name| 'completion block' }
    handle = fireball.on(event_type,
      completion: proc { |snapshot, previous_sibling_name| 'completion block' },
      disconnect: proc { 'completion block' }
      )
    handle = fireball.once(event_type) { |snapshot| 'completion block' }
    handle = fireball.once(event_type) { |snapshot, previous_sibling_name| 'completion block' }
    handle = fireball.once(event_type,
      completion: proc { |snapshot, previous_sibling_name| 'completion block' },
      disconnect: proc { 'completion block' }
      )

##### Detaching observers

    fireball.off
    fireball.off(handle)

##### Querying and limiting

    # these are not wrapped at the moment, because I don't completely understand
    # what they do.
    # fireball.queryStartingAtPriority()
    # fireball.queryStartingAtPriority(andChildName:)
    # fireball.queryEndingAtPriority()
    # fireball.queryEndingAtPriority(andChildName:)
    # fireball.queryLimitedToNumberOfChildren()

##### Managing presence

    fireball.on_disconnect(value)
    fireball.on_disconnect(value) { |error| 'completion block' }
    fireball.on_disconnect(value, priority:priority)
    fireball.on_disconnect(value, priority:priority) { |error| 'completion block' }
    fireball.on_disconnect(nil)
    fireball.on_disconnect(nil) { |error| 'completion block' }
    fireball.on_disconnect({ child: values })
    fireball.on_disconnect({ child: values }) { |error| 'completion block' }
    fireball.cancel_disconnect
    fireball.cancel_disconnect { |error| 'completion block' }

##### Authenticating

    fireball.auth(credential)
    fireball.auth(credential) { |error, data| 'completion block' }
    fireball.auth(credential,
      completion: proc { |error, data| 'completion block' },
      disconnect: proc { |error| 'completion block', },
      )
    fireball.unauth

##### Transactions

    fireball.run { |data| 'transaction block' }
    fireball.run(
      transaction: proc { |data| 'transaction block' },
      completion: proc { |error, committed, snapshot| }
      )
    fireball.run(
      transaction: proc { |data| 'transaction block' },
      completion: proc { |error, committed, snapshot| }
      local: true || false,
      )

##### Retrieving String Representation

    fireball.to_s

##### Properties

    fireball.parent
    fireball.root
    fireball.name

##### Global configuration and settings

    Fireball.dispatch_queue=(queue)
    Fireball.sdkVersion


## Properties

#### name

Gets last token in a Firebase location (e.g. ‘fred’ in https://SampleChat.firebaseIO-demo.com/users/fred))

###### Return Value

The name of the location this reference points to.


#### parent

Get a Fireball reference for the parent location. If this instance refers to the
root of your Fireball, it has no parent, and therefore parent( ) will return `nil`.

###### Return Value

A Fireball reference for the parent location.


#### root

Get a Fireball reference for the root location

###### Return Value

A new Fireball reference to root location.


## Class Methods

#### sdkVersion

Retrieve the Fireball SDK version.


#### dispatch_queue=(queue)

Set the default dispatch queue for event blocks.

###### Parameters

    queue
*The queue to set as the default for running blocks for all Fireball event
types.*

## Instance Methods


#### auth(credential, options={}, &and_then) { |error| }

###### Parameters

Authenticate access to this Fireball using the provided credentials. The
completion block will be called with the results of the authenticated attempt,
and the disconnect block will be called if the credentials become invalid at
some point after authentication has succeeded.

    credential
*The Fireball authentication JWT generated by a secure code on a remote server.*

    and_then || options[:completion]
*This block will be called with the results of the authentication attempt*

    options[:disconnect]
*This block will be called if at any time in the future the credentials become
invalid*


#### cancel_disconnect(&and_then)

Cancel any operations that are set to run on disconnect. If you previously
called `on_disconnect`, and no longer want the values updated when the
connection is lost, call `cancel_disconnect`

###### Parameters

    and_then
*A block that will be triggered once the Fireball servers have acknowledged the
cancel request.*


#### [](*children)

Get a Fireball reference for the location at the specified relative path. The
relative path can either be a simple child name (e.g. ‘fred’) or a deeper
slash-separated path (e.g. ‘fred/name/first’).

    fireball['fred']
    fireball['fred/name/first']
    fireball['fred', 'name', 'first']

###### Parameters

    children
*A relative path from this location to the desired child location(s).*

###### Return Value

A Fireball reference for the specified relative path.


#### []

`fireball[]` generates a new child location using a unique name and returns a
Fireball reference to it. This is useful when the children of a Fireball
location represent a list of items.

The unique name generated by `fireball[]` is prefixed with a client-generated
timestamp so that the resulting list will be chronologically-sorted.

###### Return Value

A Fireball reference for the generated location.


#### to_s

Gets the absolute URL of this Fireball location.


#### Fireball.new(url)

Initialize this Fireball reference with an absolute URL.

###### Parameters

    url
*The Fireball URL (ie: https://SampleChat.firebaseIO-demo.com)*


#### on(event_type, options, &and_then) { |snapshot| }
#### on(event_type, options, &and_then) { |snapshot, previous_sibling_name| }

`on()` is used to listen for data changes at a particular location. This is the
primary way to read data from Fireball. Your block will be triggered for the
initial data and again whenever the data changes.

If the block accepts two arguments, events of type `:added`, `:moved`, and
`:changed` will be passed the name of the previous node by priority order.

Use `off(handle)` to stop receiving updates.

Supported events types for all realtime observers are specified as:

    :added    # fired when a new child node is added to a location
    :removed  # fired when a child node is removed from a location
    :changed  # fired when a child node at a location changes
    :moved    # fired when a child node moves relative to the other child nodes at a location
    :value    # fired when any data changes at a location and, recursively, any children

###### Parameters

    event_type
*The type of event to listen for.*

    and_then || options[:completion]
*The block that should be called with initial data and updates as a
`FDataSnapshot`, and optionally the previous child’s name.*

    options[:disconnect]
*The block that should be called if this client no longer has permission to
receive these events*

###### Return Value

A handle used to unregister this block later using `off(handle)`


#### once(event_type, options, &and_then) { |snapshot| }
#### once(event_type, options, &and_then) { |snapshot, previous_sibling_name| }

#### observeSingleEventOfType:andPreviousSiblingNameWithBlock:

This is equivalent to `on()`, except the block is immediately canceled after the
initial data is returned.

If the block accepts two arguments, events of type `:added`, `:moved`, and
`:changed` will be passed the name of the previous node by priority order.

###### Parameters

    event_type
*The type of event to listen for.*

    and_then || options[:completion]
*The block that should be called with initial data and updates as a
`FDataSnapshot`, and optionally the previous child’s name.*

    options[:disconnect]
*The block that should be called if this client no longer has permission to
receive these events*


#### on_disconnect(nil, &and_then) { |error| }
#### on_disconnect(value, &and_then) { |error| }
#### on_disconnect(values, &and_then) { |error| }
#### on_disconnect(value, priority:priority, &and_then) { |error| }

Ensure the data at this location is removed when the client is disconnected (due
to closing the app, navigating to a new page, or network issues).

`on_disconnect` is especially useful for implementing “presence” systems.

###### Parameters
    value
*The value to be set after the connection is lost. Special value `nil` will
remove the value, and a dictionary can be sent to update multiple child node
names and the values to set them to.*

    priority
*The priority to be set after the connection is lost.*

    and_then
*Block to be triggered when the operation has been queued up on the Fireball
servers*


#### off
#### off(handle)

Detach a block previously attached with `on()`, or remove all observer events.

###### Parameters
    handle
The handle returned by the call to observeEventType:withBlock: which we are
trying to remove.  If no handle is passed, all ovservers are removed.


#### clear!(&and_then) { |error| }

Remove the data at this Fireball location. Any data at child locations will also
be deleted.

The effect of the delete will be visible immediately and the corresponding
events will be triggered. Synchronization of the delete to the Fireball servers
will also be started.

`clear!` is equivalent to calling `value(nil)`

###### Parameters
    and_then
*The block to be called after the remove has been committed to the Fireball
servers.*

#### run(options={}, &transaction) { |data| }

Performs an optimistic-concurrency transactional update to the data at this
location. Your block will be called with an FMutableData instance that contains
the current data at this location. Your block should update this data to the
value you wish to write to this location, and then return an instance of
FTransactionResult with the new data.

If, when the operation reaches the server, it turns out that this client had
stale data, your block will be run again with the latest data from the server.

When your block is run, you may decide to abort the transaction by return
`FTransactionResult.abort`.

Since your block may be run multiple times, this client could see several
immediate states that don’t exist on the server. You can suppress those
immediate states until the server confirms the final state of the transaction.

###### Parameters
    transaction || options[:transaction]
*This block receives the current data at this location and must return an
instance of FTransactionResult*

    options[:completion]
*This block will be triggered once the transaction is complete, whether it was
successful or not. It will indicate if there was an error, whether or not the
data was committed, and what the current value of the data at this location is.*

    options[:local]
*Set this to `false` to suppress events raised for intermediate states, and only
get events based on the final state of the transaction.*


#### priority=(priority)
#### priority(priority, &and_then) { |error| }

Set a priority for the data at this Fireball location. Priorities can be used to
provide a custom ordering for the children at a location (if no priorities are
specified, the children are ordered by name).

You cannot set a priority on an empty location. For this reason
`value(priority:)` should be used when setting initial data with a specific
priority and `priority()` should be used when updating the priority of existing
data.

Children are sorted based on this priority using the following rules:

Children with no priority (a `nil` priority) come first. They are ordered
lexicographically by name. Children with a priority that is parsable as a number
come next. They are sorted numerically by priority first (small to large) and
lexicographically by name second (A to z). Children with non-numeric priorities
come last. They are sorted lexicographically by priority first and
lexicographically by name second. Setting the priority to `nil` removes any
existing priority. Note that priorities are parsed and ordered as IEEE 754
double-precision floating-point numbers.

###### Parameters
    priority
*The priority to set at the specified location.*

    and_then
*The block that is triggered after the priority has been written on the
servers.*


#### value=(value)
#### value(value)

Write data to this Fireball location.

This will overwrite any data at this location and all child locations.

Data types that can be set are:

    String, 'Hello World'
    Numeric, Boolean — true, 43, 4.333
    Hash, {'key' => 'value', 'nested' => {'another': 'value' => }
    Array, []

The effect of the write will be visible immediately and the corresponding events
will be triggered. Synchronization of the data to the Fireball servers will also
be started.

Passing `nil` for the new value is equivalent to calling `clear!` all data at
this location or any child location will be deleted.

Note that `value` will remove any priority stored at this location, so if
priority is meant to be preserved, you should use `value(priority:)` instead.

Priorities are used to order items.

###### Parameters
    value
*The value to be written.*

    priority
*The priority to be attached to that data.*


#### unauth

Removes any credentials associated with this Fireball


#### update(values)
#### update(values, &and_then) { |error| }

Update changes the values of the keys specified in the dictionary without
overwriting other keys at this location.

###### Parameters
    values
*A dictionary of the keys to change and their new values*

    and_then
*The block that is triggered after the update has been written on the Fireball servers*

