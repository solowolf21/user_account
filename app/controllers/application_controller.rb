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

  def current_user_admin?
    find_current_user && find_current_user.admin?
  end

  def require_admin
    unless current_user_admin?
      flash[:alert] = 'You are not authorized!'
      redirect_to root_url
    end
  end

  helper_method :find_current_user, :current_user?, :current_user_admin?
end
