class CreateNhlgames < ActiveRecord::Migration
  def change
    create_table :nhlgames do |t|
      t.string :home
      t.string :away
      t.integer :homeW
      t.integer :homeL
      t.integer :homeOTL
      t.integer :awayW
      t.integer :awayL
      t.integer :awayOTL
      t.integer :homeGF
      t.integer :homeGA
      t.integer :awayGF
      t.integer :awayGA

      t.timestamps null: false
    end
  end
end
