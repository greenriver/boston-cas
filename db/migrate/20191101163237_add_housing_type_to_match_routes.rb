class AddHousingTypeToMatchRoutes < ActiveRecord::Migration[4.2]
  def change
    add_column :match_routes, :housing_type, :string
  end
end
