class Movie < ActiveRecord::Base
  RATINGS = %w(G PG PG-13 R NC-17)

  validates :title, :released_on, :duration, :presence => true
  validates :description, :length => {:minimum => 25}
  validates :total_gross, :numericality => {:greater_than_or_equal_to => 0}
  validates :image_file_name, :allow_blank => true, :format => {
      :with => /\w+.(gif|jpg|png)\z/i,
      :message => 'must reference a GIF, JPG, or PNG image'
  }
  validates :rating, :inclusion => { :in => RATINGS, :message=> 'is not a valid rating'}

  has_many :reviews, :dependent => :destroy
  has_many :likes, :dependent => :destroy
  has_many :likers, :through => :likes, :source => :user

  def flop?
    self.total_gross < 50000000
  end

  def self.released
    Movie.where('released_on < ?', Date.today).order('released_on desc')
  end

  def average_stars
    reviews.average(:stars)
  end
end
