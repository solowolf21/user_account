class MoviesController < ApplicationController
  before_action :require_signin, :except => [:index, :show]
  before_action :require_admin, :except => [:index, :show]
  before_action :set_movie, :only => [:show, :edit, :update, :destroy]

  def index
    case params[:scope]
      when 'hits'
        @movies = Movie.hits
      when 'flops'
        @movies = Movie.flops
      else
        @movies = Movie.released
    end
  end

  def show
    @likers = @movie.likers
    @genres = @movie.genres

    if find_current_user
      @current_like = find_current_user.likes.find_by(:movie_id => @movie.id)
    end
  end

  def edit
  end

  def update
    if @movie.update_attributes(movie_params)
      flash[:notice] = 'Movie successfully updated!'
      redirect_to @movie
    else
      render :edit
    end
  end

  def new
    @movie = Movie.new
  end

  def create
    @movie = Movie.new(movie_params)
    if @movie.save
      flash[:notice] = 'Movie successfully created!'
      redirect_to @movie
    else
      render :new
    end
  end

  def destroy
    @movie.destroy
    redirect_to movies_path, :alert => 'Movie successfully destroyed!'
  end

private
  def movie_params
    params.require(:movie).permit(:title, :description, :rating, :released_on, :total_gross, :cast, :director, :duration, :image_file_name, genre_ids:[])
  end

  def set_movie
    @movie = Movie.find_by!(:slug => params[:id])
  end
end
