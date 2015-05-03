class AppDelegate
  def application(application, didFinishLaunchingWithOptions:launchOptions)
    return true if RUBYMOTION_ENV == 'test'

    @window = UIWindow.alloc.initWithFrame(UIScreen.mainScreen.bounds)
    ctlr = MyController.new
    first = UINavigationController.alloc.initWithRootViewController(ctlr)
    @window.rootViewController = first
    @window.makeKeyAndVisible

    true
  end
end


class MyController < UITableViewController

  attr_accessor :firebase
  attr_accessor :chat

  attr_accessor :textField

  def viewDidLoad
    super

    setupNanostore

    # Pick a random number between 1-1000 for our username.
    self.title = "Guest0x#{(rand * 1000).round.to_s(16).upcase}"

    self.tableView.rowHeight = UITableViewAutomaticDimension
    self.tableView.estimatedRowHeight = 44.0
    self.tableView.dataSource = tableView.delegate = self

    self.textField = UITextField.alloc.initWithFrame([[10, 0], [CGRectGetWidth(self.tableView.bounds) - 2*10, 44]])
    self.textField.placeholder = 'Type a new item, then press enter'
    self.textField.delegate = self
    self.tableView.tableHeaderView = self.textField

    setupFirebase
  end

  def viewReload
    # When we are called, some Firebase event has occurred, so we clear the cache.
    self.chat = nil

    # Reload the table view so that new, changed or deleted messages will show up.
    # We should really buffer updates to keep the UI snappy.
    self.tableView.reloadData
  end

  def setupNanostore
    path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, true).first
    NanoStore.shared_store = NanoStore.store(:file, "#{path}/nano.db")

    # Uncomment to start with a clean store
    #NanoStore.shared_store.removeAllObjectsFromStoreAndReturnError(nil)
  end

  def setupFirebase
    # Initialize the root of our Firebase namespace.
    Firebase.url = FirechatNS
    self.firebase = Firebase.new

    self.firebase.on(:added) do |snapshot|
      # Add the chat message to the nano store
      NanoStore.addOrUpdateObjectFromDictionary(snapshot.value, key:snapshot.key)
      viewReload
    end

    self.firebase.on(:changed) do |snapshot|
      # Update the chat message with the new value(s)
      NanoStore.updateObjectWithDictionary(snapshot.value, key:snapshot.key)
      viewReload
    end

    self.firebase.on(:removed) do |snapshot|
      # Remove the chat message from the nano store
      NanoStore.removeObjectWithKey(snapshot.key)
      viewReload
    end

    # TODO: Remove chat messages that were deleted from Firebase
    # since the previous run of this app
  end

  # This method is called when the user enters text in the text field.
  # We add the chat message to our Firebase.
  def textFieldShouldReturn(text_field)
    # This will also add the message to the nano store because
    # the FEventTypeChildAdded event will be immediately fired.
    self.firebase << {'name' => self.title, 'text' => text_field.text}

    text_field.resignFirstResponder
    text_field.text = ''
    true
  end

  def chat
    # Return and cache the chat messages on first call.
    # When @chat is set to nil, the nano store will be queried again,
    # for example when new data has arrived from Firebase
    @chat ||= NanoStore.objects
  end

  def numberOfSectionsInTableView(tableView)
    1
  end

  def tableView(tableView, numberOfRowsInSection:section)
    NanoStore.count
  end

  CellIdentifier = 'Cell'
  def tableView(tableView, cellForRowAtIndexPath:indexPath)
    cell = tableView.dequeueReusableCellWithIdentifier(CellIdentifier)

    unless cell
      cell = UITableViewCell.alloc.initWithStyle(UITableViewCellStyleSubtitle, reuseIdentifier:CellIdentifier)
    end

    chatMessage = self.chat[indexPath.row]

    cell.textLabel.text = chatMessage['text']
    cell.detailTextLabel.text = chatMessage['name']

    return cell
  end

  def tableView(tableView, editActionsForRowAtIndexPath:indexPath)
    deleteAction = UITableViewRowAction.rowActionWithStyle(UITableViewRowActionStyleDestructive, title:'Delete', handler:lambda { |action, indexPath|
      # This will also remove the message from the nano store because
      # the FEventTypeChildRemoved event will be immediately fired.
      chatMessage = self.chat[indexPath.row]
      self.firebase[chatMessage.key].clear!

      # Leave editing mode after the action is performed
      tableView.editing = false
    })

    [deleteAction]
  end

  def tableView(tableView, commitEditingStyle:editingStyle, forRowAtIndexPath:indexPath)
    # required by tableView:editActionsForRowAtIndexPath:
  end
end

class NanoStore
  def self.count
    shared_store.countOfObjectsOfClassNamed(NSFNanoObject)
  end

  def self.objects
    NSLog "Reloading cache"
    sortByText = NSFNanoSortDescriptor.sortDescriptorWithAttribute('text', ascending:true)
    shared_store.objectsOfClassNamed(NSFNanoObject, usingSortDescriptors:[sortByText])
  end

  def self.objectForKey(key)
    shared_store.objectsWithKeysInArray([key]).first
  end

  def self.addObjectFromDictionary(dict, key:key)
    shared_store.addObject(NSFNanoObject.nanoObjectWithDictionary(dict, key:key), error:nil)
  end

  def self.addOrUpdateObjectFromDictionary(dict, key:key)
    object = objectForKey(key)

    if object
      # We should have a more subtle merging strategy, for example based on timestamps.
      NSLog "- merging: #{key}"
      object.addEntriesFromDictionary(dict)
      object.saveStoreAndReturnError(nil)
    else
      NSLog "- adding: #{key}"
      addObjectFromDictionary(dict, key:key)
    end
  end

  def self.updateObjectWithDictionary(dict, key:key)
    object = objectForKey(key)

    if object
      NSLog "- updating: #{key}"
      object.addEntriesFromDictionary(dict)
      object.saveStoreAndReturnError(nil)
    end
  end

  def self.removeObjectWithKey(key)
    NSLog "- removing: #{key}"
    shared_store.removeObjectsWithKeysInArray([key], error:nil)
  end
end
