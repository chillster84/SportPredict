class CreateNflgames < ActiveRecord::Migration
  def change
    create_table :nflgames do |t|
      t.string :home
      t.string :away
      t.float :homeWPct
      t.float :awayWPct

      t.timestamps null: false
    end
  end
end
