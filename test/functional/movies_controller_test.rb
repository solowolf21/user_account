require 'test_helper'

class MoviesControllerTest < ActionController::TestCase

  def setup
    @movie_1 = Movie.create_exemplar!(
        :title           => "Iron Man",
        :rating          => "PG-13",
        :total_gross     => 318412101.00,
        :description     => "Tony Stark builds an armored suit to fight the throes of evil",
        :released_on     => "2008-05-02",
        :cast            => "Robert Downey Jr., Gwyneth Paltrow and Terrence Howard",
        :director        => "Jon Favreau",
        :duration        => "126 min",
        :image_file_name => "ironman.jpg"
    )

    @movie_2 = Movie.create_exemplar!(
        :rating          => "PG",
        :total_gross     => 134218018.00,
        :description     => "Clark Kent grows up to be the greatest super-hero",
        :released_on     => "1978-12-15",
        :cast            => "Christopher Reeve, Margot Kidder and Gene Hackman",
        :director        => "Richard Donner",
        :duration        => "143 min",
        :image_file_name => "superman.jpg"
    )
    @movie_3 = Movie.create_exemplar!(
        :title           => "Spider-Man",
        :rating          => "PG-13",
        :total_gross     => 40376375.00,
        :description     => "Peter Parker gets bit by a genetically modified spider",
        :released_on     => "2002-05-03",
        :cast            => "Tobey Maguire, Kirsten Dunst and Willem Dafoe",
        :director        => "Sam Raimi",
        :duration        => "121 min",
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

  def test_index__flops
    movie = Movie.create_exemplar!(:total_gross => 5000000)
    get :index, :scope => :flops
    assert_response :success
    assert_equal 2, assigns(:movies).size
    assert_equal movie, assigns(:movies)[0]
    assert_equal @movie_3, assigns(:movies)[1]
  end

  def test_index__hits
    movie = Movie.create_exemplar!(:total_gross => 300000002, :released_on => '2008-09-03')
    get :index, :scope => :hits
    assert_response :success
    assert_equal 2, assigns(:movies).size
    assert_equal movie, assigns(:movies)[0]
    assert_equal @movie_1, assigns(:movies)[1]
  end

  def test_index__blah
    movie = Movie.create_exemplar!(:released_on => Date.today >> 1)
    get :index, :scope => :blah
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
    assert_empty assigns(:likers)
    assert_empty assigns(:genres)
  end

  def test_show__with_likers_and_genres
    genres = setup_genres
    @movie = Movie.create_exemplar!.with_likers_exemplar
    @movie.genres = genres
    @movie.save!
    get :show, :id => @movie.id
    assert_response :success
    assert_equal @movie, assigns(:movie)
    assert_equal 3, assigns(:likers).size
    assert_equal genres, assigns(:genres)
  end

  def test_show__with_likers_contain_current_user
    @user = User.create_exemplar!
    session[:user_id] = @user.id
    @movie = Movie.create_exemplar!(:likers => [@user]).with_likers_exemplar

    get :show, :id => @movie.id

    assert_response :success
    assert_equal @movie, assigns(:movie)
    assert_equal 4, assigns(:likers).size
    assert_not_nil assigns(:current_like)
  end

  def test_show__with_likers_do_not_contain_current_user
    @user             = User.create_exemplar!
    session[:user_id] = @user.id
    @movie            = Movie.create_exemplar!(:likers => [User.create_exemplar!]).with_likers_exemplar

    get :show, :id => @movie.id

    assert_response :success
    assert_equal @movie, assigns(:movie)
    assert_equal 4, assigns(:likers).size
    assert_nil assigns(:current_like)
  end

  def test_edit__without_signed_in
    assert_no_difference ('Movie.count') do
      get :edit, :id => @movie_1.id
    end

    assert_redirected_to new_session_path
    assert_equal 'Please Sign In First!', flash[:alert]
  end

  def test_edit__with_non_admin_user
    user_signed_in
    assert_no_difference ('Movie.count') do
      get :edit, :id => @movie_1.id
    end
    assert_redirected_to root_url
    assert_equal 'You are not authorized!', flash[:alert]
  end

  def test_edit__with_admin_user
    user_signed_in(true)
    assert_no_difference ('Movie.count') do
      get :edit, :id => @movie_1.id
    end

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

  def test_update__without_signed_in
    assert_no_difference ('Movie.count') do
      put :update, params.merge(:id => @movie_1.id)
    end
    assert_redirected_to new_session_path
    assert_equal 'Please Sign In First!', flash[:alert]
  end

  def test_update__with_non_admin_user
    user_signed_in
    assert_no_difference ('Movie.count') do
      put :update, params.merge(:id => @movie_1.id)
    end
    assert_redirected_to root_url
    assert_equal 'You are not authorized!', flash[:alert]
  end

  def test_update__with_admin_user
    user_signed_in(true)
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
    assert_equal 3, @movie_1.genres.size
  end

  def test_new__without_signed_in
    assert_no_difference ('Movie.count') do
      get :new
    end
    assert_redirected_to new_session_path
    assert_equal 'Please Sign In First!', flash[:alert]
  end

  def test_new__with_non_admin_user
    user_signed_in
    assert_no_difference ('Movie.count') do
      get :new
    end
    assert_redirected_to root_url
    assert_equal 'You are not authorized!', flash[:alert]
  end

  def test_new__with_admin_user
    user_signed_in(true)
    assert_no_difference ('Movie.count') do
      get :new
      assert_response :success
      assert_not_nil assigns(:movie)
    end
  end

  def test_create__without_signed_in
    assert_no_difference ('Movie.count') do
      post :create, params
    end
    assert_redirected_to new_session_path
    assert_equal 'Please Sign In First!', flash[:alert]
  end

  def test_create__with_non_admin_user
    user_signed_in
    assert_no_difference ('Movie.count') do
      post :create, params
    end
    assert_redirected_to root_url
    assert_equal 'You are not authorized!', flash[:alert]
  end

  def test_create__with_admin_user
    user_signed_in(true)
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
    assert_equal 3, assigns(:movie).genres.size

    assert_redirected_to assigns(:movie)
    assert_equal 'Movie successfully created!', flash[:notice]
  end

  def test_destroy__without_signed_in
    assert_no_difference ('Movie.count') do
      delete :destroy, :id => @movie_1.id
    end
    assert_redirected_to new_session_path
    assert_equal 'Please Sign In First!', flash[:alert]
  end

  def test_destroy__with_non_admin_user
    user_signed_in(false)
    assert_no_difference ('Movie.count') do
      delete :destroy, :id => @movie_1.id
    end
    assert_redirected_to root_url
    assert_equal 'You are not authorized!', flash[:alert]
  end

  def test_destroy__with_admin_user
    user_signed_in(true)
    assert_difference ('Movie.count'), -1 do
      delete :destroy, :id => @movie_1.id
    end
    assert_redirected_to movies_path
    assert_equal 'Movie successfully destroyed!', flash[:alert]
  end

  private
  def params
    genre_ids = []
    setup_genres.each do |g|
      genre_ids << g.id
    end

    {:movie => {
        :title           => 'Donut',
        :rating          => 'PG-13',
        :released_on     => '2011-09-05',
        :description     => 'This Donut is so sweet! Really really sweet!',
        :total_gross     => 987654321,
        :cast            => 'Tom',
        :director        => 'Mike Bay',
        :duration        => '100min',
        :image_file_name => 'transformer.jpg',
        :genre_ids       => genre_ids
    }}
  end

  def user_signed_in(admin=false)
    @user             = admin ? User.create_exemplar!.admin_exemplar : User.create_exemplar!
    session[:user_id] = @user.id
  end

  def setup_genres
    g1 = Genre.create_exemplar!(:name => 'Action')
    g2 = Genre.create_exemplar!(:name => 'Comedy')
    g3 = Genre.create_exemplar!(:name => 'Sci')
    [g1, g2, g3]
  end
end
