module ApplicationHelper
  def find_current_user(id)
    User.find(id) if id
  end
end
