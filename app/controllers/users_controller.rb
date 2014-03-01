class UsersController < ApplicationController
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
    @user = User.find(params[:id])
  end

  def update
    @user = User.find(params[:id])
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
  end

  def destory
    @user = User.find(params[:id])
    @user.destory
    redirect_to root_url, :alert => 'User successfully destroyed!'
  end

  private
  def users_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation)
  end
end
