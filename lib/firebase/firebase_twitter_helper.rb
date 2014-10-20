# see https://www.firebase.com/docs/ios/guide/login/twitter.html for more info
# (that's where this code came from)
class Firebase
  def self.twitter_api_key=(value)
    @twitter_api_key = value
  end
  def self.twitter_api_key
    @twitter_api_key
  end
  def self.open_twitter_session(options={}, &block)
    self.new.open_twitter_session(options={}, &block)
  end

  def open_twitter_session(options={}, &block)
    ref = self
    api_key = options[:api_key] || Firebase.twitter_api_key
    raise "api_key is required in #{__method__}" unless api_key

    helper = Motion::Firebase::TwitterAuthHelper.new(ref, api_key)
    helper.select_twitter_account(&block)
    nil
  end
end


module Motion
module Firebase
class TwitterAuthHelper

  def initialize(ref, api_key)
    @store = ACAccountStore.new
    @ref = ref
    @api_key = api_key
    @account = nil
    @acounts = nil
    @firebase_callback = nil
  end

  # Step 1a -- get account
  def select_twitter_account(&callback)
    account_type = @store.accountTypeWithAccountTypeIdentifier(ACAccountTypeIdentifierTwitter)

    @store.requestAccessToAccountsWithType(account_type, options: nil, completion: -> (granted, error) do
      if granted
        @accounts = @store.accountsWithAccountType(account_type)
        if @accounts.length > 0
          Dispatch::Queue.main.async do
            next_step = -> (account, &firebase_handler) do
              self.authenticate_account(account, &firebase_handler)
            end
            callback.call(nil, @accounts, next_step)
          end if callback
        else
          error = NSError.alloc.initWithDomain('TwitterAuthHelper',
                         code: AuthHelperErrorAccountAccessDenied,
                     userInfo: { NSLocalizedDescriptionKey => 'No Twitter accounts detected on phone. Please add one in the settings first.' })
          Dispatch::Queue.main.async do
            callback.call(error, nil, nil)
          end if callback
        end
      else
        error = NSError.alloc.initWithDomain('TwitterAuthHelper',
                       code: AuthHelperErrorAccountAccessDenied,
                   userInfo: { NSLocalizedDescriptionKey => 'Access to twitter accounts denied.' })
        Dispatch::Queue.main.async do
          callback.call(error, nil, nil)
        end if callback
      end
    end)
  end

  # Last public facing method
  def authenticate_account(account, &firebase_handler)
    if !account
      error = NSError.alloc.initWithDomain('TwitterAuthHelper',
                   code: AuthHelperErrorAccountAccessDenied,
                   userInfo: { NSLocalizedDescriptionKey => 'No Twitter account to authenticate.' })
      Dispatch::Queue.main.async do
        firebase_handler.call(error, nil)
      end if firebase_handler
    else
      @account = account
      @firebase_callback = firebase_handler
      make_reverse_request # kick off step 1b
    end
  end

  def callback_if_exists_with_error(error)
    if @firebase_callback
      Dispatch::Queue.main.async do
        @firebase_callback.call(error, nil)
      end
    end
  end

  # Step 1b -- get request token from Twitter
  def make_reverse_request
    @ref.makeReverseOAuthRequestTo('twitter', withCompletionBlock: -> (error, json) do
      if error
        callback_if_exists_with_error(error)
      else
        request = create_credential_request_with_reverse_auth_payload(json)
        request_twitter_credentials(request)
      end
    end)
  end

  # Step 1b Helper -- creates request to Twitter
  def create_credential_request_with_reverse_auth_payload(json)
    params = {}

    request_token = json['auth']
    params['x_reverse_auth_parameters'] = request_token
    params['x_reverse_auth_target'] = @api_key

    url = NSURL.URLWithString('https://api.twitter.com/oauth/access_token')
    req = SLRequest.requestForServiceType(SLServiceTypeTwitter, requestMethod: SLRequestMethodPOST, URL: url, parameters: params)
    req.setAccount(@account)

    req
  end

  # Step 2 -- request credentials from Twitter
  def request_twitter_credentials(request)
    request.performRequestWithHandler(-> (response_data, url_response, error) do
      if error
        callback_if_exists_with_error(error)
      else
        authenticate_with_twitter_credentials(response_data)
      end
    end)
  end

  # Step 3 -- authenticate with Firebase using Twitter credentials
  def authenticate_with_twitter_credentials(response_data)
    params = parse_twitter_credentials(response_data)
    if params['error']
      error = NSError.alloc.initWithDomain('TwitterAuthHelper',
                   code: AuthHelperErrorOAuthTokenRequestDenied,
                   userInfo: { NSLocalizedDescriptionKey => 'OAuth token request was denied.',
                               'details' => params['error']})
      callback_if_exists_with_error(error)
    else
      @ref.authWithOAuthProvider('twitter', parameters: params, withCompletionBlock: @firebase_callback)
    end
  end

  # Step 3 Helper -- parsers credentials into dictionary
  def parse_twitter_credentials(response_data)
    account_data = NSString.alloc.initWithData(response_data, encoding:NSUTF8StringEncoding)
    params = {}

    account_data.split('&').each do |param|
      key, value = param.split('=')
      params[key] = value
    end

    # This is super fragile error handling, but basically check that the token and token secret are there.
    # If not, return the result that Twitter returned.
    if params['oauth_token_secret'] && params['oauth_token']
      params
    else
      { 'error' => account_data }
    end
  end

end
end
end