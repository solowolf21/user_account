class SessionsController < ApplicationController
  def new
  end

  def create
    if user = User.authenticate(params[:session][:email], params[:session][:password])
      session[:user_id] = user.id
      flash[:notice]    = "Welcome back, #{user.name}!"
      redirect_to(session[:intended_url] || user)
      session[:intended_url] = nil
    else
      flash.now[:alert] = 'Invalid email/password combination.'
      render :new
    end
  end

  def destroy
    session[:user_id] = nil
    flash[:notice] = 'You have been successfully signed out!'
    redirect_to root_url
  end
end
