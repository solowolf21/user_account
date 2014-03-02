require 'test_helper'
class MoviesHelperTest < ActionView::TestCase
  def setup
    @movie_1 = Movie.create_exemplar!(
        :title => "Iron Man",
        :rating => "PG-13",
        :total_gross => 318412101.00,
        :description => "Tony Stark builds an armored suit to fight the throes of evil",
        :released_on => "2008-05-02",
        :cast => "Robert Downey Jr., Gwyneth Paltrow and Terrence Howard",
        :director => "Jon Favreau",
        :duration => "126 min",
        :image_file_name => "ironman.jpg"
    )

    @movie_2 = Movie.create_exemplar!(
        :title => "Superman",
        :rating => "PG",
        :total_gross => 134218018.00,
        :description => "Clark Kent grows up to be the greatest super-hero",
        :released_on => "1978-12-15",
        :cast => "Christopher Reeve, Margot Kidder and Gene Hackman",
        :director => "Richard Donner",
        :duration => "143 min",
        :image_file_name => "superman.jpg"
    )
    @movie_3 = Movie.create_exemplar!(
        :title => "Spider-Man",
        :rating => "PG-13",
        :total_gross => 40376375.00,
        :description => "Peter Parker gets bit by a genetically modified spider",
        :released_on => "2002-05-03",
        :cast => "Tobey Maguire, Kirsten Dunst and Willem Dafoe",
        :director => "Sam Raimi",
        :duration => "121 min",
        :image_file_name => ""
    )
  end

  def test_format_total_gross
    assert_equal '$318,412,101.00', view.format_total_gross(@movie_1)
    assert_equal '<strong>Flop!</strong>', view.format_total_gross(@movie_3)
  end

  def test_format_average_stars
    assert_equal '<strong>No reviews</strong>', view.format_average_stars(@movie_1)

    Review.create_exemplar!(:movie => @movie_1, :stars => 1)
    Review.create_exemplar!(:movie => @movie_1, :stars => 2)
    Review.create_exemplar!(:movie => @movie_1, :stars => 3)

    @movie_1.reload
    assert_equal '2.0 stars', view.format_average_stars(@movie_1)

    Review.create_exemplar!(:movie => @movie_1, :stars => 5)

    @movie_1.reload
    assert_equal '2.8 stars', view.format_average_stars(@movie_1)
  end

end