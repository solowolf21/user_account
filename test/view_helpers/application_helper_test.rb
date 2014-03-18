require 'test_helper'

class ApplicationHelperTest < ActionView::TestCase
  def test_page_title
    assert_false content_for?(:title)

    assert_equal 'User Account', page_title

    content_for(:title, 'Foobar')
    assert content_for?(:title)
    assert_equal 'User Account - Foobar', page_title
  end
end
