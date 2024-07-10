class AddMatchRouteParkingColumns < ActiveRecord::Migration[7.0]
  def change
    add_column :match_routes, :routes_parked_on_active_match, :text
    add_column :match_routes, :routes_parked_on_successful_match, :text

    MatchRoutes::Base.all.each do |route| 
      success_route_array = if route.should_cancel_other_matches
        MatchRoutes::Base.all.map {|r| r.class.to_s }
      else
        [route.class.to_s]
      end
      active_route_array = [route.class.to_s] if route.should_prevent_multiple_matches_per_client
      route.update(
        routes_parked_on_successful_match: success_route_array,
        routes_parked_on_active_match: active_route_array,
        )
    end  
  end
end
