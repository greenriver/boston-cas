class AddStalledIntervalToMatchRoutes < ActiveRecord::Migration
  def change
    add_column :match_routes, :stalled_interval, :integer, null: false, default: 7 
    remove_column :configs, :stalled_interval, :integer, null: false, default: 7 
  end
end
