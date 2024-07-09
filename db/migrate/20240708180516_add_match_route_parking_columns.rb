class AddMatchRouteParkingColumns < ActiveRecord::Migration[7.0]
  def change
    add_column :match_routes, :routes_parked_on_active_match, :text
    add_column :match_routes, :routes_parked_on_successful_match, :text
  end
end
