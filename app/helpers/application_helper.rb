module ApplicationHelper
  def page_title
    if content_for?(:title)
      "User Account - #{content_for(:title)}"
    else
      'User Account'
    end
  end
end
