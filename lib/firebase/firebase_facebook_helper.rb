# see https://www.firebase.com/docs/ios/guide/login/facebook.html for more info
# (that's where this code came from)
class Firebase
  def self.open_facebook_session(options={}, &block)
    self.new.open_facebook_session(options={}, &block)
  end

  def open_facebook_session(options={}, &block)
    ref = self
    permissions = options[:permissions] || ['public_profile']
    allow_ui = options.fetch(:allow_login_ui, true)
    FBSession.openActiveSessionWithReadPermissions(permissions, allowLoginUI: allow_ui,
      completionHandler: -> (session, state, error) do
        if error
          block.call(error, nil)
        elsif state == FBSessionStateOpen
          token = session.accessTokenData.accessToken

          ref.authWithOAuthProvider('facebook', token:token, withCompletionBlock:block)
        end
      end)
    nil
  end
end
