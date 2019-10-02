class AddMatchRouteToMatches < ActiveRecord::Migration
  def change
    add_belongs_to :client_opportunity_matches, :match_route
  end
end
