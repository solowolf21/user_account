class ApplicationController < ActionController::Base
  protect_from_forgery

private
  def require_signin
    unless find_current_user
      session[:intended_url] = request.url
      flash[:alert] = 'Please Sign In First!'
      redirect_to new_session_path
    end
  end

  def find_current_user
    User.find(session[:user_id]) if session[:user_id]
  end

  def current_user?(user)
    find_current_user == user
  end

  helper_method :find_current_user, :current_user?
end
