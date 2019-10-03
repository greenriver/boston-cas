class AddMatchRouteToMatches < ActiveRecord::Migration
  def change
    add_column :client_opportunity_matches, :match_route_id, :integer
  end
end
