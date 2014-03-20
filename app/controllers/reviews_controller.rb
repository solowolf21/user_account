class ReviewsController < ApplicationController
  before_filter :require_signin
  before_filter :set_movie

  def index
    @reviews = @movie.reviews
  end

  def new
    @review = @movie.reviews.new
  end

  def create
    @review = @movie.reviews.new(review_params)
    @review.user = find_current_user

    if @review.save
      redirect_to movie_reviews_path(@movie), :notice => 'Thanks for your review!'
    else
      render :new
    end
  end

  private
  def review_params
    params.require(:review).permit(:stars, :comment)
  end

  def set_movie
    @movie = Movie.find_by!(:slug => params[:movie_id])
  end
end
