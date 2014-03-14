require 'test_helper'

class LikesControllerTest < ActionController::TestCase
  setup :set_up_movie

  def test_create_with_signin
    sign_in_user
    assert_difference ('Like.count') do
      post :create, :movie_id => @movie.id
    end

    @user.reload
    assert_equal 1, @user.liked_movies.size
    assert_equal @movie, @user.liked_movies.first
  end

  def test_create_without_signin
    assert_no_difference ('Like.count') do
      post :create, :movie_id => @movie.id
    end

    assert_redirected_to new_session_path
    assert_equal 'Please Sign In First!', flash[:alert]
  end

  def test_destroy_with_signin
    sign_in_user
    @user.liked_movies << @movie
    @user.save!

    assert_equal 1, @user.liked_movies.size
    assert_equal @movie, @user.liked_movies.first

    assert_difference ('Like.count'), -1 do
      delete :destroy, :movie_id => @movie.id, :id => @user.likes.first.id
    end
    @user.reload
    assert_equal 0, @user.liked_movies.size
    assert_equal 0, @movie.likers.size
  end

  def test_destroy_without_signin
    @user = User.create_exemplar!(:liked_movies => [@movie])
    assert_no_difference ('Like.count') do
      delete :destroy, :movie_id => @movie.id, :id => @user.likes.first.id
    end

    assert_redirected_to new_session_path
    assert_equal 'Please Sign In First!', flash[:alert]
  end

  private
  def set_up_movie
    @movie = Movie.create_exemplar!
  end

  def sign_in_user
    @user             = User.create_exemplar!
    session[:user_id] = @user.id
  end
end
