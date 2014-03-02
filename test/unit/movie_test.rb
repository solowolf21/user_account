require 'test_helper'

class MovieTest < ActiveSupport::TestCase
  def test_flop
    movie = Movie.create_exemplar!(:total_gross => 1)
    assert movie.flop?
    movie.update_attributes!(:total_gross => 50000001)
    assert_not movie.flop?
  end

  def test_setter_getter
    movie = Movie.create_exemplar!
    movie.title           = 'Flix'
    movie.rating          = 'PG-13'
    movie.description     = 'The movie is fair. Watch it if you really have time.'
    movie.released_on     = '2011-08-06'
    movie.total_gross     = 7777777
    movie.cast            = 'Tom'
    movie.director        = 'Mike Bay'
    movie.duration        = '2h30min'
    movie.image_file_name = 'transformer.jpg'
    movie.save!

    movie.reload
    assert_equal 'Flix',               movie.title
    assert_equal 'PG-13',              movie.rating
    assert_equal 'The movie is fair. Watch it if you really have time.', movie.description
    assert_equal 'Sat, 06 Aug 2011',   movie.released_on.inspect
    assert_equal 7777777,              movie.total_gross
    assert_equal 'Tom',                movie.cast
    assert_equal 'Mike Bay',           movie.director
    assert_equal '2h30min',            movie.duration
    assert_equal 'transformer.jpg',    movie.image_file_name
  end

  def test_released
    movie_1 = Movie.create_exemplar!(:released_on => Date.today << 12)
    movie_2 = Movie.create_exemplar!(:released_on => Date.today >> 5)
    movie_3 = Movie.create_exemplar!(:released_on => Date.today << 9)
    movie_4 = Movie.create_exemplar!(:released_on => Date.today << 22)

    movies = Movie.released
    assert_equal 3, movies.size
    assert_equal movie_3, movies[0]
    assert_equal movie_1, movies[1]
    assert_equal movie_4, movies[2]
  end

  def test_validations
    movie = Movie.new

    assert_not movie.valid?
    assert_no_difference ('Movie.count') do
      movie.save
    end
    assert_equal ["can't be blank"], movie.errors[:title]
    assert_equal ["can't be blank"], movie.errors[:released_on]
    assert_equal ["can't be blank"], movie.errors[:duration]
    assert_equal ["is too short (minimum is 25 characters)"], movie.errors[:description]
    assert_equal ["is not a number"], movie.errors[:total_gross]
    assert_equal ["is not a valid rating"], movie.errors[:rating]

    movie.title = 'The Avengers'
    movie.released_on = '2012-05-04'
    movie.duration = '142 min'
    movie.description = 'The ultimate Super Hero team-up of a lifetime!'
    movie.total_gross = -2
    movie.rating = 'PG-13'

    assert_not movie.valid?
    assert_no_difference ('Movie.count') do
      movie.save
    end
    assert movie.errors[:title].empty?
    assert movie.errors[:released_on].empty?
    assert movie.errors[:duration].empty?
    assert movie.errors[:description].empty?
    assert_equal ["must be greater than or equal to 0"], movie.errors[:total_gross]
    assert movie.errors[:rating].empty?

    movie.total_gross = 100000000
    movie.image_file_name = 'avengers.jpg'
    assert movie.valid?

    assert_difference ('Movie.count') do
      movie.save
    end
  end

  def test_average_stars
    @movie = Movie.create_exemplar!
    assert_nil @movie.average_stars

    Review.create_exemplar!(:movie => @movie, :stars => 1)
    Review.create_exemplar!(:movie => @movie, :stars => 2)
    Review.create_exemplar!(:movie => @movie, :stars => 3)

    assert_equal 2, @movie.average_stars
  end
end
