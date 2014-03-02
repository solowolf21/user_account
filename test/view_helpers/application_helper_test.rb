require 'test_helper'

class ApplicationHelperTest < ActionView::TestCase

  def test_find_current_user
    assert_nil find_current_user
    @user = User.create_exemplar!
    assert_equal @user, find_current_user(@user.id)
  end
end
