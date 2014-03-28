require 'test_helper'

class MovieTest < ActiveSupport::TestCase
  def test_flop
    movie = Movie.create_exemplar!(:total_gross => 1)
    assert movie.flop?
    movie.update_attributes!(:total_gross => 50000001)
    assert_not movie.flop?
  end

  def test_hit
    movie = Movie.create_exemplar!(:total_gross => 1)
    assert_not movie.hit?
    movie.update_attributes!(:total_gross => 300000000)
    assert movie.hit?
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
    assert_equal 'movie698481name',    movie.slug
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

  def test_likers
    @movie = Movie.create_exemplar!.with_likers_exemplar
    assert_equal 3, @movie.likes.size
    assert_equal 3, @movie.likers.size
  end

  def test_scope_released
    setup_movies

    movies = Movie.released
    assert_equal 6, movies.size
    assert_equal @movie_3, movies[0]
    assert_equal @movie_6, movies[1]
    assert_equal @movie_2, movies[2]
    assert_equal @movie_1, movies[3]
    assert_equal @movie_5, movies[4]
    assert_equal @movie_4, movies[5]
  end

  def test_scope_flops
    setup_movies

    movies = Movie.flops
    assert_equal 3, movies.size
    assert_equal @movie_3, movies[0]
    assert_equal @movie_2, movies[1]
    assert_equal @movie_4, movies[2]
  end

  def test_scope_hits
    setup_movies

    movies = Movie.hits
    assert_equal 3, movies.size
    assert_equal @movie_6, movies[0]
    assert_equal @movie_1, movies[1]
    assert_equal @movie_5, movies[2]
  end

  def test_scope_upcoming
    setup_movies

    movies = Movie.upcoming
    assert_equal 3, movies.size
    assert_equal @movie_8, movies[0]
    assert_equal @movie_9, movies[1]
    assert_equal @movie_7, movies[2]
  end

  def test_scope_rated
    setup_movies

    movies = Movie.rated('PG-13')
    assert_equal 3, movies.size
    assert_equal @movie_1, movies[0]
    assert_equal @movie_5, movies[1]
    assert_equal @movie_4, movies[2]
  end

  def test_scope_recent
    setup_movies

    movies = Movie.recent(6)
    assert_equal 6, movies.size

    assert_equal @movie_3, movies[0]
    assert_equal @movie_6, movies[1]
    assert_equal @movie_2, movies[2]
    assert_equal @movie_1, movies[3]
    assert_equal @movie_5, movies[4]
    assert_equal @movie_4, movies[5]
  end

  def test_to_params
    movie = Movie.create_exemplar!(:title => 'Awesome')
    assert_equal 'awesome', movie.slug
  end

  private
  def setup_movies
    @movie_1 = Movie.create_exemplar!(:total_gross => 300000000, :released_on => Date.today << 12, :rating => 'PG-13')
    @movie_2 = Movie.create_exemplar!(:total_gross => 30000, :released_on => Date.today << 10, :rating => 'G')
    @movie_3 = Movie.create_exemplar!(:total_gross => 7000000, :released_on => Date.today << 1, :rating => 'PG')
    @movie_4 = Movie.create_exemplar!(:total_gross => 600000, :released_on => Date.today << 19, :rating => 'PG-13')
    @movie_5 = Movie.create_exemplar!(:total_gross => 3000900000, :released_on => Date.today << 14, :rating => 'PG-13')
    @movie_6 = Movie.create_exemplar!(:total_gross => 4000000009, :released_on => Date.today << 9, :rating => 'R')
    @movie_7 = Movie.create_exemplar!(:total_gross => 900090000, :released_on => Date.today >> 19)
    @movie_8 = Movie.create_exemplar!(:total_gross => 900090000, :released_on => Date.today >> 8)
    @movie_9 = Movie.create_exemplar!(:total_gross => 900090000, :released_on => Date.today >> 10)
  end
end
