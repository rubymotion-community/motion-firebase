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


end