require 'test_helper'

class UsersControllerTest < ActionController::TestCase
  def test_new
    assert_no_difference ('User.count') do
      get :new
      assert_response :success
      assert_not_nil assigns(:user)
    end
  end

  def test_create
    assert_difference ('User.count') do
      post :create, params
    end

    assert_equal 'kevin', assigns(:user).name
    assert_equal 'kevin@user.com', assigns(:user).email
    assert_equal 'kevin_secret', assigns(:user).password

    assert_redirected_to assigns(:user)
    assert_equal 'A new user was successfully created.', flash[:notice]
  end

  def test_index__with_sign_in
    setup_users
    session[:user_id] = @user_1.id
    get :index
    assert_response :success

    assert_equal 3, assigns(:users).size
    assert_equal @user_1, assigns(:users)[0]
    assert_equal @user_2, assigns(:users)[1]
    assert_equal @user_3, assigns(:users)[2]
  end

  def test_index__without_sign_in
    setup_users
    get :index
    assert_equal 'Please Sign In First!', flash[:alert]
    assert_redirected_to new_session_path
  end

  def test_show__with_sign_in
    @user             = User.create_exemplar!
    session[:user_id] = @user.id
    get :show, :id => @user.id
    assert_response :success
    assert_equal @user, assigns(:user)
  end

  def test_show__with_sign_in_and_liked_movies
    @user             = User.create_exemplar!.with_liked_movies_exemplar
    session[:user_id] = @user.id
    get :show, :id => @user.id
    assert_response :success
    assert_equal @user, assigns(:user)
    assert_equal 3, assigns(:liked_movies).size
  end

  def test_show__without_sign_in
    @user = User.create_exemplar!
    get :show, :id => @user.id
    assert_equal 'Please Sign In First!', flash[:alert]
    assert_redirected_to new_session_path
  end

  def test_update__with_sign_in__with_corrent_user
    @user             = User.create_exemplar!(:name => 'User')
    session[:user_id] = @user.id
    assert_equal 'User', @user.name
    assert_equal 'user@user.com', @user.email
    assert_equal 'secret', @user.password

    assert_no_difference ('User.count') do
      put :update, params.merge(:id => @user.id)
      assert_equal 'User information has been successfully updated.', flash[:notice]
      assert_redirected_to @user
    end

    @user.reload
    assert_equal 'kevin', @user.name
    assert_equal 'kevin@user.com', @user.email
    assert User.authenticate(@user.email, 'kevin_secret')
  end

  def test_update__with_sign_in__without_corrent_user
    setup_users
    session[:user_id] = @user_2.id
    assert_equal 'Jim', @user_1.name
    assert_equal 'jim@user.com', @user_1.email
    assert_equal 'jim_secret', @user_1.password

    assert_no_difference ('User.count') do
      put :update, params.merge(:id => @user_1.id)
      assert_redirected_to root_url
    end
  end

  def test_update__without_sign_in
    @user = User.create_exemplar!(:name => 'User')
    assert_equal 'User', @user.name
    assert_equal 'user@user.com', @user.email
    assert_equal 'secret', @user.password

    assert_no_difference ('User.count') do
      put :update, params.merge(:id => @user.id)
      assert_equal 'Please Sign In First!', flash[:alert]
      assert_redirected_to new_session_path
    end
  end

  def test_destroy__with_sign_in__with_corrent_user
    setup_users
    session[:user_id] = @user_1.id
    assert_difference ('User.count'), -1 do
      delete :destroy, :id => @user_1.id
    end

    assert_nil session[:user_id]
    assert_redirected_to root_url
    assert_equal 'User successfully destroyed!', flash[:alert]
  end

  def test_destroy__with_sign_in__without_corrent_user
    setup_users
    session[:user_id] = @user_2.id
    assert_no_difference 'User.count' do
      delete :destroy, :id => @user_1.id
      assert_redirected_to root_url
    end
  end

  def test_destroy__without_sign_in
    setup_users
    assert_no_difference 'User.count' do
      delete :destroy, :id => @user_1.id
      assert_equal 'Please Sign In First!', flash[:alert]
      assert_redirected_to new_session_path
    end
  end

  private
  def setup_users
    @user_1 = User.create_exemplar!(
        :name     => 'Jim',
        :email    => 'jim@user.com',
        :password => 'jim_secret'
    )

    @user_2 = User.create_exemplar!(
        :name     => 'Tim',
        :email    => 'tim@user.com',
        :password => 'tim_secret'
    )

    @user_3 = User.create_exemplar!(
        :name     => 'Kim',
        :email    => 'kim@user.com',
        :password => 'kim_secret'
    )
  end

  def params
    {:user => {
        :name                  => 'kevin',
        :email                 => 'kevin@user.com',
        :password              => 'kevin_secret',
        :password_confirmation => 'kevin_secret'
    }}
  end

end