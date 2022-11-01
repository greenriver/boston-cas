class AddExpectsRoiToRoutes < ActiveRecord::Migration[6.0]
  def change
    add_column :match_routes, :expects_roi, :boolean, default: true
  end
end
