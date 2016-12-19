module SessionAuthenticator
  module_function

  def authenticate(session)
    return false unless ensure_keys(session)
    return false if session[:last_accessed] < 30.minutes.ago.utc
    Member.find(session[:current_user_id]) || false
  end

  def ensure_keys(session)
    %i(last_accessed current_user_id).all? { |key| session[key].present? }
  end
end
