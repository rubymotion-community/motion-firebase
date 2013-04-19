class FirebaseAuthClient

  def self.new(ref)
    alloc.initWithRef(ref)
  end

  def check(&and_then)
    checkAuthStatusWithBlock(and_then)
  end

  def create(credentials, &block)
    email = credentials[:email]
    raise "email is required in #{__method__}" unless email
    password = credentials[:password]
    raise "password is required in #{__method__}" unless password
    createUserWithEmail(email, password:password, andCompletionBlock:block)
  end

  def remove(credentials, &block)
    email = credentials[:email]
    raise "email is required in #{__method__}" unless email
    password = credentials[:password]
    raise "password is required in #{__method__}" unless password
    removeUserWithEmail(email, password:password, andCompletionBlock:block)
  end

  def login(credentials, &block)
    email = credentials[:email]
    raise "email is required in #{__method__}" unless email
    password = credentials[:password]
    raise "password is required in #{__method__}" unless password
    loginWithEmail(email, andPassword:password, withCompletionBlock:block)
  end

  def update(credentials, &block)
    email = credentials[:email]
    raise "email is required in #{__method__}" unless email
    old_password = credentials[:old_password]
    raise "old_password is required in #{__method__}" unless old_password
    new_password = credentials[:new_password]
    raise "new_password is required in #{__method__}" unless new_password
    changePasswordForEmail(email, oldPassword:old_password, newPassword:new_password, completionBlock:block)
  end

  def login_facebook(credentials, &block)
    app_id = credentials[:app_id]
    raise "app_id is required in #{__method__}" unless app_id
    permissions = credentials[:permissions]
    raise "permissions is required in #{__method__}" unless permissions
    loginToFacebookAppWithId(app_id, permissions:permissions, withCompletionBlock:block)
  end

  def login_to_twitter(credentials, &block)
    app_id = credentials[:app_id]
    raise "app_id is required in #{__method__}" unless app_id
    on_multiple = credentials[:on_multiple]
    raise "on_multiple is required in #{__method__}" unless on_multiple
    loginToTwitterAppWithId(app_id, multipleAccountsHandler:on_multiple, withCompletionBlock:block)
  end

  def inspect
    "#<#{self.class}:0x#{self.object_id.to_s(16)}>"
  end

end
