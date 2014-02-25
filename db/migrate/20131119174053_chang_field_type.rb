class ChangFieldType < ActiveRecord::Migration
  def up
    change_column :movies, :released_on, :date
  end

  def down
    change_column :movies, :released_on, :datetime
  end
end
