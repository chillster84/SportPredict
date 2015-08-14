class AddDate2ToMlbgames < ActiveRecord::Migration
  def change
    add_column :mlbgames, :date, :date, after: :id
  end
end
