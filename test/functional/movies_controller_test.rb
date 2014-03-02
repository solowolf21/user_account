require 'test_helper'

class MoviesControllerTest < ActionController::TestCase

  def setup
    @movie_1 = Movie.create_exemplar!(
        :title => 'Superman',
        :rating => 'PG-13',
        :total_gross => '1234124312349.99',
        :description => 'This man is super cool! This man is super cool! This man is super cool! This man is super cool!',
        :released_on => '2013-11-19',
        :duration => '150min',
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
        :title => 'Iron man',
        :rating => 'NC-17',
        :total_gross => '898124312349.99',
        :description => 'Iron man is super awesome! Iron man is super awesome! Iron man is super awesome! Iron man is super awesome!',
        :released_on => '2011-01-29',
        :duration => '120min',
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
        :title => 'Spiderman',
        :rating => 'PG',
        :total_gross => '123419.99',
        :description => 'Spider man is a dumb! Spider man is a dumb! Spider man is a dumb! Spider man is a dumb!',
        :released_on => '2009-10-13',
        :duration => '140min',
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

  def test_index
    movie = Movie.create_exemplar!(:released_on => Date.today >> 1)
    get :index
    assert_response :success
    assert_equal 3, assigns(:movies).size
    assert_equal @movie_1, assigns(:movies)[0]
    assert_equal @movie_3, assigns(:movies)[1]
    assert_equal @movie_2, assigns(:movies)[2]
  end

  def test_show
    get :show, :id => @movie_1.id
    assert_response :success
    assert_equal @movie_1, assigns(:movie)
  end

  def test_edit
    get :edit, :id => @movie_1.id

    assert_response :success
    assert_template 'edit'
    assert_equal @movie_1, assigns(:movie)
    assert_equal 'Iron Man', @movie_1.title
    assert_equal 'PG-13', @movie_1.rating
    assert_equal 'Tony Stark builds an armored suit to fight the throes of evil', @movie_1.description
    assert_equal 'Fri, 02 May 2008', @movie_1.released_on.inspect
    assert_equal 318412101.00, @movie_1.total_gross
    assert_equal "Robert Downey Jr., Gwyneth Paltrow and Terrence Howard", @movie_1.cast
    assert_equal 'Jon Favreau', @movie_1.director
    assert_equal '126 min', @movie_1.duration
    assert_equal 'ironman.jpg', @movie_1.image_file_name
  end

  def test_update
    assert_no_difference ('Movie.count') do
      put :update, params.merge(:id => @movie_1.id)
      assert_redirected_to @movie_1
    end

    @movie_1.reload

    assert_equal 'Movie successfully updated!', flash[:notice]
    assert_equal 'Donut', @movie_1.title
    assert_equal 'PG-13', @movie_1.rating
    assert_equal 'Mon, 05 Sep 2011', @movie_1.released_on.inspect
    assert_equal 'This Donut is so sweet! Really really sweet!', @movie_1.description
    assert_equal 987654321, @movie_1.total_gross
    assert_equal 'Tom', @movie_1.cast
    assert_equal 'Mike Bay', @movie_1.director
    assert_equal '100min', @movie_1.duration
    assert_equal 'transformer.jpg', @movie_1.image_file_name
  end

  def test_new
    assert_no_difference ('Movie.count') do
      get :new
      assert_response :success
      assert_not_nil assigns(:movie)
    end
  end

  def test_create
    assert_difference ('Movie.count') do
      post :create, params
    end

    assert_equal 'Donut', assigns(:movie).title
    assert_equal 'PG-13', assigns(:movie).rating
    assert_equal 'Mon, 05 Sep 2011', assigns(:movie).released_on.inspect
    assert_equal 'This Donut is so sweet! Really really sweet!', assigns(:movie).description
    assert_equal 987654321, assigns(:movie).total_gross
    assert_equal 'Tom', assigns(:movie).cast
    assert_equal 'Mike Bay', assigns(:movie).director
    assert_equal '100min', assigns(:movie).duration
    assert_equal 'transformer.jpg', assigns(:movie).image_file_name

    assert_redirected_to assigns(:movie)
    assert_equal 'Movie successfully created!', flash[:notice]
  end

  def test_destroy
    assert_difference ('Movie.count'), -1 do
      delete :destroy, :id => @movie_1.id
    end
    assert_redirected_to movies_path
    assert_equal 'Movie successfully destroyed!', flash[:alert]
  end

private
  def params
    {:movie => {
        :title => 'Donut',
        :rating => 'PG-13',
        :released_on => '2011-09-05',
        :description => 'This Donut is so sweet! Really really sweet!',
        :total_gross => 987654321,
        :cast => 'Tom',
        :director => 'Mike Bay',
        :duration => '100min',
        :image_file_name => 'transformer.jpg'
    }}
  end
end
