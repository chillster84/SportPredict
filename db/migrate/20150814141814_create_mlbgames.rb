class CreateMlbgames < ActiveRecord::Migration
  def change
    create_table :mlbgames do |t|
      t.string :away
      t.string :home

      t.timestamps null: false
    end
  end
end
