class UsersController < ApplicationController
  before_action :require_signin, :except => [:new, :create]
  before_action :require_correct_user, :only => [:edit, :update, :destroy]

  def new
    @user = User.new
  end

  def create
    @user = User.new(users_params)
    if @user.save
      session[:user_id] = @user.id
      flash[:notice] = "A new user was successfully created."
      redirect_to @user
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @user.update_attributes(users_params)
      flash[:notice] = "User information has been successfully updated."
      redirect_to @user
    else
      render :edit
    end
  end

  def index
    @users = User.all
  end

  def show
    @user = User.find(params[:id])
    @liked_movies = @user.liked_movies
  end

  def destroy
    @user.destroy
    session[:user_id] = nil
    redirect_to root_url, :alert => 'User successfully destroyed!'
  end

  private
  def users_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation)
  end

  def require_correct_user
    @user = User.find(params[:id])
    unless current_user?(@user)
      redirect_to root_url
    end
  end
end
