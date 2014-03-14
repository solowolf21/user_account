require 'exemplar_builder'
class Exemplars
  extend ExemplarBuilder

  exemplify Movie do |obj, count, overrides|
    obj.title = "Movie#{count}Name"
    obj.rating = ['G', 'PG', 'PG-13', 'R', 'NC-17'].sample
    obj.released_on = Date.today << 12 * rand(10)
    obj.description = "#{obj.title} is really really good. " * 4
    obj.total_gross = rand(100000000)
    obj.duration = ['90min', '95min', '100min', '115min', '120min', '150min'].sample
  end

  exemplify Movie, :with_likers do |obj, count, overrides|
    3.times do
      obj.likers << User.create_exemplar!
    end
  end

  exemplify Review do |obj, count, overrides|
    obj.stars = overrides.delete(:stars) || [1, 2, 3, 4, 5].sample
    obj.comment = "It's pretty good."
    obj.movie = overrides.delete(:movie) || Movie.create_exemplar!
    obj.user = overrides.delete(:user) || User.create_exemplar!
  end

  exemplify User do |obj, count, overrides|
    obj.name = overrides.delete(:name) || "User#{count}"
    obj.email = overrides.delete(:email) || "#{obj.name.dup.downcase}@user.com"
    obj.password = overrides.delete(:password) || 'secret'
    obj.password_confirmation = obj.password
    obj.admin =  overrides.delete(:admin) || false
  end

  exemplify User, :admin do |obj, count, overrides|
    obj.admin = true
  end

  exemplify User, :with_liked_movies do |obj, count, overrides|
    3.times do
      obj.liked_movies << Movie.create_exemplar!
    end
  end
end
