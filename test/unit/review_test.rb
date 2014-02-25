require 'test_helper'

class ReviewTest < ActiveSupport::TestCase
  def test_setter_getter
    review = Review.create_exemplar!
    movie = Movie.create_exemplar!

    review.name = 'Jim'
    review.stars = 5
    review.comment = 'What a good movie!'
    review.movie = movie

    review.save!

    review.reload

    assert_equal 'Jim', review.name
    assert_equal 5, review.stars
    assert_equal 'What a good movie!', review.comment
    assert_equal movie, review.movie
  end

  def test_validations
    review = Review.new
    assert !review.valid?
    assert_no_difference ('Review.count') do
      review.save
    end

    assert_equal ["can't be blank"], review.errors[:name]
    assert_equal ["can't be blank", "must be between 1 and 5"], review.errors[:stars]
    assert_equal ["can't be blank", "is too short (minimum is 4 characters)"], review.errors[:comment]

    review.name = 'Jim'
    review.stars = 5
    review.comment = 'What a good movie!'
    review.movie = Movie.create_exemplar!

    assert_difference ('Review.count') do
      review.save
    end
  end

  def test_association
    assert_difference ('Movie.count') do
      assert_difference ('Review.count'), 3 do
        @movie = Movie.create_exemplar!
        review_1 = Review.create_exemplar!(:movie => @movie)
        review_2 = Review.create_exemplar!(:movie => @movie)
        review_3 = Review.create_exemplar!(:movie => @movie)
      end
    end

    assert_difference ('Movie.count'), -1 do
      assert_difference ('Review.count'), -3 do
        @movie.destroy
      end
    end
  end

end
