class Genre < ActiveRecord::Base
  validates_presence_of :name
  validates_uniqueness_of :name

  has_many :characterizations, :dependent => :destroy
  has_many :movies, :through => :characterizations
end
