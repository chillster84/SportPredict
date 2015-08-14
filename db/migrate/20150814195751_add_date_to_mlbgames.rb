class AddDateToMlbgames < ActiveRecord::Migration
  def change
    change_column :mlbgames, :date, :date, after: :id
  end
end
