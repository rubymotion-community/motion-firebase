class FirebaseSimpleLogin

  def self.new(ref)
    alloc.initWithRef(ref)
  end

  def check(&and_then)
    checkAuthStatusWithBlock(and_then)
  end

  def create(credentials, &block)
    raise "email is required in #{__method__}" unless credentials.key?(:email)
    raise "password is required in #{__method__}" unless credentials.key?(:password)
    email = credentials[:email]
    password = credentials[:password]
    begin
      createUserWithEmail(email, password:password, andCompletionBlock:block)
    rescue RuntimeError => e
      block.call(e, nil)
    end
  end

  def remove(credentials, &block)
    raise "email is required in #{__method__}" unless credentials.key?(:email)
    raise "password is required in #{__method__}" unless credentials.key?(:password)
    email = credentials[:email]
    password = credentials[:password]
    removeUserWithEmail(email, password:password, andCompletionBlock:block)
  end

  def login(credentials, &block)
    raise "email is required in #{__method__}" unless credentials.key?(:email)
    raise "password is required in #{__method__}" unless credentials.key?(:password)
    email = credentials[:email]
    password = credentials[:password]
    begin
      loginWithEmail(email, andPassword:password, withCompletionBlock:block)
    rescue RuntimeError => e
      block.call(e, nil)
    end
  end

  def update(credentials, &block)
    raise "email is required in #{__method__}" unless credentials.key?(:email)
    raise "old_password is required in #{__method__}" unless credentials.key?(:old_password)
    raise "new_password is required in #{__method__}" unless credentials.key?(:new_password)
    email = credentials[:email]
    old_password = credentials[:old_password]
    new_password = credentials[:new_password]
    changePasswordForEmail(email, oldPassword:old_password, newPassword:new_password, completionBlock:block)
  end

  def login_to_facebook(credentials, &block)
    if credentials.is_a?(NSString)
      app_id = credentials
      credentials = {}
    else
      app_id = credentials[:app_id]
      raise "app_id is required in #{__method__}" unless app_id
    end
    permissions = credentials[:permissions] || ['email']
    audience = credentials[:audience] || ACFacebookAudienceOnlyMe
    loginToFacebookAppWithId(app_id, permissions:permissions, audience:audience, withCompletionBlock:block)
  end

  def login_to_twitter(credentials, &block)
    if credentials.is_a?(String)
      app_id = credentials
      credentials = {}
    else
      app_id = credentials[:app_id]
      raise "app_id is required in #{__method__}" unless app_id
    end
    on_multiple = credentials[:on_multiple] || ->(accounts) { accounts[0] }
    loginToTwitterAppWithId(app_id, multipleAccountsHandler:on_multiple, withCompletionBlock:block)
  end

  # def inspect
  #   "#<#{self.class}:0x#{self.object_id.to_s(16)}>"
  # end

end
