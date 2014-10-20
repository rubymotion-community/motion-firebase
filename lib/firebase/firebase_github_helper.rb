# see https://www.firebase.com/docs/ios/guide/login/github.html for more info
# (that's where this code came from)
class Firebase
  def self.github_token=(value)
    @github_token = value
  end
  def self.github_token
    @github_token
  end
  def self.open_github_session(options={}, &block)
    self.new.open_github_session(options={}, &block)
  end

  def open_github_session(options={}, &block)
    ref = self
    token = options[:token] || Firebase.github_token
    raise "token is required in #{__method__}" unless token
    firebase_ref.login_to_github('github', token)
  end
end
