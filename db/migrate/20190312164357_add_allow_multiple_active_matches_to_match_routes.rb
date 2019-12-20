class AddAllowMultipleActiveMatchesToMatchRoutes < ActiveRecord::Migration[4.2]
  def change
    add_column :match_routes, :allow_multiple_active_matches, :boolean, default: false, null: false
  end
end
