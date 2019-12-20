class AddMatchRouteToMatches < ActiveRecord::Migration[4.2]
  def change
    add_column :client_opportunity_matches, :match_route_id, :integer
  end
end
