FirechatNS = 'https://firechat-ios.firebaseio-demo.com/'

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


class MyController < UIViewController

  attr_accessor :chat
  attr_accessor :firebase

  attr_accessor :nameField
  attr_accessor :textField
  attr_accessor :tableView

  def loadView
    super

    self.nameField = UIButton.rounded
    self.nameField.frame = [[20, 20], [280, 44]]
    self.nameField.autoresizingMask = UIViewAutoresizingFlexibleWidth
    self.view << self.nameField

    self.tableView = UITableView.plain
    self.tableView.frame = [[20, 71], [280, 419]]
    self.tableView.rowHeight = 44
    self.tableView.delegate = self
    self.tableView.dataSource = self
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight
    self.view << self.tableView

    self.textField = UITextField.alloc.initWithFrame([[20, 464], [280, 30]])
    self.textField.borderStyle = UITextBorderStyleRoundedRect
    self.textField.autoresizingMask = UIViewAutoresizingFlexibleWidth
    self.textField.delegate = self
    self.view << self.textField
  end

  def viewDidLoad
    super

    # Initialize array that will store chat messages.
    self.chat = []

    # Initialize the root of our Firebase namespace.
    self.firebase = Firebase.new(FirechatNS)

    # Pick a random number between 1-1000 for our username.
    self.title = "Guest0x#{(rand * 1000).round.to_s(16).upcase}"
    nameField.setTitle(self.title, forState:UIControlStateNormal)

    self.firebase.on(:added) do |snapshot|
      # Add the chat message to the array.
      self.chat << snapshot.value
      # Reload the table view so the new message will show up.
      self.tableView.reloadData
    end
  end


  # This method is called when the user enters text in the text field.
  # We add the chat message to our Firebase.
  def textFieldShouldReturn(text_field)
    text_field.resignFirstResponder

    # This will also add the message to our local array self.chat because
    # the FEventTypeChildAdded event will be immediately fired.
    self.firebase << {'name' => self.title, 'text' => text_field.text}

    text_field.text = ''
    false
  end

  def numberOfSectionsInTableView(tableView)
    1
  end

  def tableView(tableView, numberOfRowsInSection:section)
    self.chat.length
  end

  CellIdentifier = 'Cell'
  def tableView(tableView, cellForRowAtIndexPath:index_path)
    cell = tableView.dequeueReusableCellWithIdentifier(CellIdentifier)

    unless cell
      cell = UITableViewCell.alloc.initWithStyle(UITableViewCellStyleSubtitle, reuseIdentifier:CellIdentifier)
    end

    chatMessage = self.chat[index_path.row]

    cell.textLabel.text = chatMessage['text']
    cell.detailTextLabel.text = chatMessage['name']

    return cell
  end

  # Subscribe to keyboard show/hide notifications.
  def viewWillAppear(animated)
    super
    UIKeyboardWillShowNotification.add_observer(self, 'keyboardWillShow:')
    UIKeyboardWillHideNotification.add_observer(self, 'keyboardWillHide:')
  end

  # Unsubscribe from keyboard show/hide notifications.
  def viewWillDisappear(animated)
    super
    UIKeyboardWillShowNotification.remove_observer(self)
    UIKeyboardWillHideNotification.remove_observer(self)
  end

  # Setup keyboard handlers to slide the view containing the table view and
  # text field upwards when the keyboard shows, and downwards when it hides.
  def keyboardWillShow(notification)
    self.moveView(notification.userInfo, up:true)
  end

  def keyboardWillHide(notification)
    self.moveView(notification.userInfo, up:false)
  end

  def moveView(userInfo, up:up)
    keyboardEndFrame = userInfo[UIKeyboardFrameEndUserInfoKey].CGRectValue

    animationCurve = userInfo[UIKeyboardAnimationCurveUserInfoKey]
    animationDuration = userInfo[UIKeyboardAnimationDurationUserInfoKey]

    # Get the correct keyboard size to we slide the right amount.
    UIView.animate(duration:animationDuration, options:animationCurve | UIViewAnimationOptionBeginFromCurrentState) do
      keyboardFrame = self.view.convertRect(keyboardEndFrame, toView:nil)
      y = keyboardFrame.size.height * (up ? -1 : 1)
      self.view.frame = CGRectOffset(self.view.frame, 0, y)
    end
  end

  # This method will be called when the user touches on the tableView, at
  # which point we will hide the keyboard (if open). This method is called
  # because UITouchTableView.m calls nextResponder in its touch handler.
  def touchesBegan(touches, withEvent:event)
    if textField.isFirstResponder
      textField.resignFirstResponder
    end
  end

end
