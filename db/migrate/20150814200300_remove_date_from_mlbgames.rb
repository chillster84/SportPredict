class RemoveDateFromMlbgames < ActiveRecord::Migration
  def change
  	remove_column :mlbgames, :date
  	remove_column :mlbgames, :homeWPct
  	remove_column :mlbgames, :awayWPct
  end
end
