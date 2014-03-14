class ChangeReviewsTableToAJoinTable < ActiveRecord::Migration
  def self.up
    add_column :reviews, :user_id, :integer

    execute <<-SQL
      update reviews r
        inner join users u
           on r.name = u.name
      set r.user_id = u.id;
    SQL

    remove_columns :reviews, :name
  end

  def self.down
    add_column :reviews, :name, :string

    execute <<-SQL
      update reviews r
        inner join users u
          on r.user_id = u.id
      set r.name = u.name;
    SQL

    remove_column :reviews, :user_id
  end
end
