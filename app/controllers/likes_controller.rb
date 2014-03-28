class LikesController < ApplicationController
  before_filter :require_signin, :set_up_movie

  def create
    @movie.likes.create!(:user => find_current_user)

    flash[:notice] = 'You have liked the movie!'
    redirect_to @movie
  end

  def destroy
    like = find_current_user.likes.find(params[:id])
    like.destroy

    flash[:notice] = 'Successfully unliked!'
    redirect_to @movie
  end

private
  def set_up_movie
    @movie = Movie.find(params[:movie_id])
  end
end
