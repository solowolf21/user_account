class User < ActiveRecord::Base
  has_secure_password

  has_many :reviews, :dependent => :destroy
  has_many :likes, :dependent => :destroy
  has_many :liked_movies, :through => :likes, :source => :movie

  validates :name,  :presence => true
  validates :email, :presence => true,
                    :format => /\A\S+@\S+\z/,
                    :uniqueness => { :case_sensitive => false }
  validates :password, :length => { :minimum => 6 }

  def self.authenticate(email, password)
    user = User.find_by(:email => email)
    user && user.authenticate(password)
  end
end
