class AddStatsToMlbgames < ActiveRecord::Migration
  def change
    add_column :mlbgames, :homeWPct, :float
    add_column :mlbgames, :awayWPct, :float
  end
end
