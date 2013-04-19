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

  def inspect
    "#<#{self.class}:0x#{self.object_id.to_s(16)}>"
  end

end
