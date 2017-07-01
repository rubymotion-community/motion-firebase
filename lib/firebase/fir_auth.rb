class FIRAuth


  def logout
    signOut(nil)
  end


  def authenticated?(&block)
    !!currentUser
  end


  def authenticate(token, options={}, &and_then)
    and_then ||= options[:completion]
    signInWithCustomToken(token, completion: and_then)
    return self
  end
  
  def login(credentials, &and_then)
    raise ":email is required in #{__method__}" unless credentials.key?(:email)
    raise ":password is required in #{__method__}" unless credentials.key?(:password)
    email = credentials[:email]
    password = credentials[:password]
    signInWithEmail(email, password: password, completion: and_then)
    return self
  end
  
  def self.open_facebook_session(options={}, &block)
    self.new.open_facebook_session(options={}, &block)
  end
  
  def open_facebook_session(options={}, &block)
    ref = self
    permissions = options[:permissions] || ['email']
    fb_login = FBSDKLoginManager.alloc.init
    fb_login.logInWithReadPermissions(permissions, 
      handler: -> (facebookResult, facebookError) do
        if facebookError
          block.call(facebookError, nil)
        elsif facebookResult.isCancelled
          block.call("Facebook login got cancelled.", nil)
        else
          credentials = FIRFacebookAuthProvider.credentialWithAccessToken(FBSDKAccessToken.currentAccessToken.tokenString)
          ref.signInWithCredential(credentials, completion: block)
        end
      end)
    nil
  end

  def self.update_user_email(credentials, &block)
    self.new.update_user_email(credentials, &block)
  end
  
  def update_user_email(credentials, &block)
    raise ":email is required in #{__method__}" unless credentials.key?(:email)
    email = credentials[:email]
    currentUser.updateEmail(email, completion: block)
  end
  
  def self.update_password(credentials, &block)
    self.new.update_user(credentials, &block)
  end
  
  def update_password(credentials, &block)
    raise ":new_password is required in #{__method__}" unless credentials.key?(:new_password)
    new_password = credentials[:new_password]
    currentUser.updatePassword(new_password, completion: block)
  end
  
  def self.create_user_and_login(credentials, &block)
    self.new.create_user_and_login(credentials, &block)
  end
  
  def create_user_and_login(credentials, &block)
    raise ":email is required in #{__method__}" unless credentials.key?(:email)
    raise ":password is required in #{__method__}" unless credentials.key?(:password)
    email = credentials[:email]
    password = credentials[:password]
    begin
      createUserWithEmail(email, password: password, completion: -> (user, error) do
        if error
          block.call(error, nil)
        else
          login(credentials, &block)
        end
      end)
    rescue RuntimeError => e
      block.call(e, nil)
    end
  end
  
  def self.send_password_reset(credentials, &block)
    self.new.send_password_reset(credentials, &block)
  end
  
  def send_password_reset(email, &block)
    sendPasswordResetWithEmail(email, completion: block)
  end
  
  def check_provider_from_email(email, &block)
    fetchProvidersForEmail(email, completion: block)
  end
  
  def reauthenticate_user(credentials, &block)
    raise ":email is required in #{__method__}" unless credentials.key?(:email)
    raise ":password is required in #{__method__}" unless credentials.key?(:password)
    email = credentials[:email]
    password = credentials[:password]
    newCredentials = FIREmailPasswordAuthProvider.credentialWithEmail(email, password: password)
    currentUser.reauthenticateWithCredential(newCredentials, completion: block)
  end

end