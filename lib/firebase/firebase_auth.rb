# most methods have a static version that make use of Firebase.url = 'global url'
# to create a Firebase ref.
class Firebase

  def self.auth_data
    Firebase.new.auth_data
  end
  def auth_data
    authData
  end

  # @example
  #     Firebase.authenticate('secrettoken') do |error, auth_data|
  #       if auth_data
  #         # authenticated
  #       end
  #     end
  def self.authenticate(token, options={}, &block)
    Firebase.new.authenticate(token, options, &block)
  end
  def authenticate(token, options={}, &and_then)
    and_then ||= options[:completion]
    disconnect_block = options[:disconnect]
    if disconnect_block || and_then.arity < 2
      NSLog('Warning!  The Firebase authWithCredential method is deprecated.')
      NSLog('Instead of using a completion and cancel block, pass one block:')
      NSLog('fb.auth(token) do |error, auth_data| .. end')
      authWithCredential(token, withCompletionBlock:and_then, withCancelBlock: disconnect_block)
    else
      authWithCustomToken(token, withCompletionBlock: and_then)
    end
    return self
  end

  def self.logout(&block)
    Firebase.new.logout(&block)
  end
  def logout(&block)
    if block_given?
      unauthWithCompletionBlock(block)
    else
      unauth
    end
  end

  def self.authenticated?(&block)
    Firebase.new.authenticated?(&block)
  end
  # checks the authenticated status.  If you pass a block the
  # observeAuthEventWithBlock is used to determine the status.  If you don't
  # pass a block, this method returns true or false.
  def authenticated?(&block)
    if block
      observeAuthEventWithBlock(block)
    else
      !!authData
    end
  end

  # You should call this when you no longer need `authenticated?` data.
  def self.off_auth(handler)
    Firebase.new.off_auth(handler)
  end
  def off_auth(handler)
    removeAuthEventObserverWithHandle(handler)
  end

  def self.create_user(credentials, &block)
    Firebase.new.create_user(credentials, &block)
  end
  def create_user(credentials, &block)
    raise ":email is required in #{__method__}" unless credentials.key?(:email)
    raise ":password is required in #{__method__}" unless credentials.key?(:password)
    email = credentials[:email]
    password = credentials[:password]
    begin
      if block && block.arity == 2
        createUser(email, password: password, withValueCompletionBlock: block)
      else
        createUser(email, password: password, withCompletionBlock: block)
      end
    rescue RuntimeError => e
      block.call(e, nil)
    end
  end

  def self.create_user_and_login(credentials, &block)
    Firebase.new.create_user_and_login(credentials, &block)
  end
  def create_user_and_login(credentials, &block)
    raise ":email is required in #{__method__}" unless credentials.key?(:email)
    raise ":password is required in #{__method__}" unless credentials.key?(:password)
    email = credentials[:email]
    password = credentials[:password]
    begin
      createUser(email, password: password, withCompletionBlock: -> (error) do
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

  def self.update_user(credentials, &block)
    Firebase.new.update_user(credentials, &block)
  end
  def update_user(credentials, &block)
    raise ":email is required in #{__method__}" unless credentials.key?(:email)
    raise ":old_password is required in #{__method__}" unless credentials.key?(:old_password)
    raise ":new_password is required in #{__method__}" unless credentials.key?(:new_password)
    email = credentials[:email]
    old_password = credentials[:old_password]
    new_password = credentials[:new_password]
    changePasswordForUser(email, fromOld: old_password, toNew: new_password, withCompletionBlock: block)
  end

  def self.send_password_reset(credentials, &block)
    Firebase.new.send_password_reset(credentials, &block)
  end
  def send_password_reset(email, &block)
    resetPasswordForUser(email, withCompletionBlock: block)
  end

  def self.remove_user(credentials, &block)
    Firebase.new.remove_user(credentials, &block)
  end
  def remove_user(credentials, &block)
    raise ":email is required in #{__method__}" unless credentials.key?(:email)
    raise ":password is required in #{__method__}" unless credentials.key?(:password)
    email = credentials[:email]
    password = credentials[:password]
    removeUser(email, password: password, withCompletionBlock: block)
  end

  def login_anonymously(&block)
    authAnonymouslyWithCompletionBlock(block)
  end

  def login(credentials, &block)
    raise ":email is required in #{__method__}" unless credentials.key?(:email)
    raise ":password is required in #{__method__}" unless credentials.key?(:password)
    email = credentials[:email]
    password = credentials[:password]
    begin
      authUser(email, password: password, withCompletionBlock: block)
    rescue RuntimeError => e
      block.call(e, nil)
    end
  end

  def login_to_oauth(provider, parameters={}, &block)
    if parameters.is_a?(NSString)
      token = parameters
    elsif parameters.key?(:token)
      token = parameters[:token]
    else
      token = nil
    end

    if token
      authWithOAuthProvider(provider, token: token, withCompletionBlock: block)
    else
      objc_params = {}
      parameters.each do |key, value|
        # explicitly convert :sym to 'sym'
        objc_params[key.to_s] = value
      end
      authWithOAuthProvider(provider, parameters: objc_params, withCompletionBlock: block)
    end
  end

  def login_to_facebook(credentials, &block)
    if credentials.is_a?(NSString)
      token = credentials
    else
      token = credentials[:token]
    end
    raise ":token is required in #{__method__}" unless token

    authWithOAuthProvider('facebook', token: token, withCompletionBlock: block)
  end

  def login_to_twitter(credentials, &block)
    oauth_token = credentials[:token] || credentials[:oauth_token]
    oauth_token_secret = credentials[:secret] || credentials[:oauth_token_secret]
    raise ":token is required in #{__method__}" unless oauth_token
    raise ":secret is required in #{__method__}" unless oauth_token_secret

    provider = 'twitter'
    options = {
      'oauth_token' => oauth_token,
      'oauth_token_secret' => oauth_token_secret,
    }
    login_to_oauth(provider, options, &block)
  end

  def login_to_github(credentials, &block)
    if credentials.is_a?(NSString)
      token = credentials
    else
      token = credentials[:token]
    end
    raise ":token is required in #{__method__}" unless token

    authWithOAuthProvider('github', token: token, withCompletionBlock: block)
  end

  def login_to_google(credentials, &block)
    if credentials.is_a?(NSString)
      token = credentials
    else
      token = credentials[:token]
    end
    raise ":token is required in #{__method__}" unless token

    authWithOAuthProvider('google', token: token, withCompletionBlock: block)
  end

end
