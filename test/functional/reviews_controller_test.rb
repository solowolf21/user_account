require 'test_helper'

class ReviewsControllerTest < ActionController::TestCase
  def setup
    @movie = Movie.create_exemplar!
  end

  def test_index
    user_signin
    @review_1 = Review.create_exemplar!(:movie => @movie)
    @review_2 = Review.create_exemplar!(:movie => @movie)
    @review_3 = Review.create_exemplar!(:movie => @movie)

    get :index, :movie_id => @movie.slug
    assert_response :success

    @reviews = assigns(:reviews)

    assert_equal 3, @reviews.size
    assert_equal @review_1, @reviews[0]
    assert_equal @review_2, @reviews[1]
    assert_equal @review_3, @reviews[2]
  end

  def test_index__without_signin
    @review_1 = Review.create_exemplar!(:movie => @movie)
    @review_2 = Review.create_exemplar!(:movie => @movie)
    @review_3 = Review.create_exemplar!(:movie => @movie)

    get :index, :movie_id => @movie.slug
    assert_equal 'Please Sign In First!', flash[:alert]
    assert_redirected_to new_session_path
  end

  def test_new
    user_signin
    assert_no_difference ('Review.count') do
      get :new, :movie_id => @movie.slug
      assert_response :success
    end
  end

  def test_new__without_signin
    assert_no_difference ('Review.count') do
      get :new, :movie_id => @movie.slug
      assert_equal 'Please Sign In First!', flash[:alert]
      assert_redirected_to new_session_path
    end
  end

  def test_create
    user_signin
    assert_difference ('Review.count') do
      post :create, params

      assert_redirected_to movie_reviews_path(@movie)
      assert_equal 'Thanks for your review!', flash[:notice]
    end
  end

  def test_create__without_signin
    assert_no_difference ('Review.count') do
      post :create, params

      assert_equal 'Please Sign In First!', flash[:alert]
      assert_redirected_to new_session_path
    end
  end

  private

  def params
    {
        :movie_id => @movie.slug,
        :review   => {
            :stars   => '5',
            :comment => 'Awesome!'
        }
    }
  end

  def user_signin
    user              = User.create_exemplar!
    session[:user_id] = user.id
  end

end
