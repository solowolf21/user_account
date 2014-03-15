require 'test_helper'

class GenreTest < ActiveSupport::TestCase

  def test_name
    g = Genre.new
    assert !g.valid?
    assert_equal ["Name can't be blank"], g.errors.full_messages

    g.name = 'Action'
    assert g.valid?

    Genre.create_exemplar!(:name => 'Action')

    assert !g.valid?
    assert_equal ["Name has already been taken"], g.errors.full_messages

    g.name = "Comedy"
    assert g.valid?
  end

  def test_getter_and_setter
    g = Genre.create_exemplar!(:name => 'Action')
    assert_equal 'Action', g.name

    g.name = 'Comedy'
    g.save!
    assert_equal 'Comedy', g.name
  end

end
