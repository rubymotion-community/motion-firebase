class FirebaseSimpleLogin

  def self.new(ref, options=nil)
    if options
      alloc.initWithRef(ref, options: options)
    else
      alloc.initWithRef(ref)
    end
  end

  def check(&and_then)
    checkAuthStatusWithBlock(and_then)
  end

  def update(credentials, &block)
    raise "email is required in #{__method__}" unless credentials.key?(:email)
    raise "old_password is required in #{__method__}" unless credentials.key?(:old_password)
    raise "new_password is required in #{__method__}" unless credentials.key?(:new_password)
    email = credentials[:email]
    old_password = credentials[:old_password]
    new_password = credentials[:new_password]
    changePasswordForEmail(email, oldPassword: old_password, newPassword: new_password, completionBlock: block)
  end

end
