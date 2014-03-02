require 'test_helper'

class SessionsControllerTest < ActionController::TestCase
  def test_create__success
    @user = User.create_exemplar!(:name => 'Kim', :password => 'kevin_secret')
    post :create, {:session => {:email => 'kim@user.com', :password => 'kevin_secret'}}
    assert_equal @user.id, session[:user_id]
    assert_equal 'Welcome back, Kim!', flash[:notice]
    assert_redirected_to @user
  end

  def test_create__fail
    User.stubs(:authenticate).returns(false)
    post :create, {:session => {:email => 'foo@bar.com', :password => 'foobar'}}
    assert_equal 'Invalid email/password combination.', flash[:alert]
    assert_template :new
  end

  def test_destroy
    session[:user_id] = 1
    assert_not_nil session[:user_id]
    delete :destroy
    assert_nil session[:user_id]
    assert_equal 'You have been successfully signed out!', flash[:notice]
    assert_redirected_to root_url
  end
end