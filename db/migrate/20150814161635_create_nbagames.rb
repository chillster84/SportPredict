class CreateNbagames < ActiveRecord::Migration
  def change
    create_table :nbagames do |t|
      t.string :home
      t.string :away
      t.float :homeWPct
      t.float :awayWPct
      t.float :homePPG
      t.float :awayPPG

      t.timestamps null: false
    end
  end
end
