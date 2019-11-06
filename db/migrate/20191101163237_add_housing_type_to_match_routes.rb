class AddHousingTypeToMatchRoutes < ActiveRecord::Migration
  def change
    add_column :match_routes, :housing_type, :string
  end
end
