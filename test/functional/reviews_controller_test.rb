require 'test_helper'

class ReviewsControllerTest < ActionController::TestCase
  def setup
    @movie = Movie.create_exemplar!
  end

  def test_index
    @review_1 = Review.create_exemplar!(:movie => @movie)
    @review_2 = Review.create_exemplar!(:movie => @movie)
    @review_3 = Review.create_exemplar!(:movie => @movie)

    get :index, :movie_id => @movie.id
    assert_response :success

    @reviews = assigns(:reviews)

    assert_equal 3, @reviews.size
    assert_equal @review_1, @reviews[0]
    assert_equal @review_2, @reviews[1]
    assert_equal @review_3, @reviews[2]
  end

  def test_new
    assert_no_difference ('Review.count') do
      get :new, :movie_id => @movie.id
      assert_response :success
      assert_not_nil assigns(:review)
      assert_equal @movie, assigns(:review).movie
    end
  end

  def test_create
    assert_difference ('Review.count') do
      post :create, params

      assert_redirected_to movie_reviews_path(@movie)
      assert_equal 'Thanks for your review!', flash[:notice]
    end
  end

  private

  def params
    {
      :movie_id => @movie.id,
      :review => {
        :name => 'Jim',
        :stars => '5',
        :comment => 'Awesome!'
     }
    }
  end

end
