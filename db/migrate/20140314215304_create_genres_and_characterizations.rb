class CreateGenresAndCharacterizations < ActiveRecord::Migration
  def change
    create_table :genres do |t|
      t.string :name

      t.timestamps
    end

    create_table :characterizations do |t|
      t.references :movie, index: true
      t.references :genre, index: true

      t.timestamps
    end
  end
end
