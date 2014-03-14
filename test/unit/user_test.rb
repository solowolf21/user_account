require 'test_helper'

class UserTest < ActiveSupport::TestCase
  def test_setter_getter
    @user                       = User.create_exemplar!
    @user.name                  = 'Jim'
    @user.email                 = 'jim@user.com'
    @user.password              = 'secret'
    @user.password_confirmation = 'secret'
    @user.admin                 = true

    @user.save!
    @user.reload

    assert_equal 'Jim', @user.name
    assert_equal 'jim@user.com', @user.email
    assert @user.admin?
    assert User.authenticate('jim@user.com', 'secret')
  end

  def test_validations
    @user = User.new
    assert_not @user.valid?

    assert_equal ["can't be blank"], @user.errors[:name]
    assert_equal ["can't be blank", "is invalid"], @user.errors[:email]
    assert_equal ["can't be blank", "is too short (minimum is 6 characters)"], @user.errors[:password]

    @user.name                  = 'test'
    @user.email                 = 'test.user.com'
    @user.password              = 'secret'
    @user.password_confirmation = 'secret1'

    assert_not @user.valid?
    assert_equal ["is invalid"], @user.errors[:email]
    assert_equal ["doesn't match Password"], @user.errors[:password_confirmation]

    @user.email                 = 'test@user.com'
    @user.password_confirmation = 'secret'
    assert @user.valid?
  end

  def test_authentication
    User.delete_all
    @user = User.create_exemplar!(:name => 'Paul', :email => 'paul@user.com', :password => 'secret_pwd')
    assert_not User.authenticate('test@user.com', 'secret')
    assert_not User.authenticate('paul@user.com', 'secret')
    assert_not User.authenticate('test@user.com', 'secret_pwd')

    assert User.authenticate('paul@user.com', 'secret_pwd')
  end

  def test_like
    @user = User.create_exemplar!.with_liked_movies_exemplar
    assert_equal 3, @user.likes.size
    assert_equal 3, @user.liked_movies.size
  end
end