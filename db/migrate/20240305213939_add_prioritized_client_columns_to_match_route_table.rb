class AddPrioritizedClientColumnsToMatchRouteTable < ActiveRecord::Migration[6.1]
  def change
    add_column :match_routes, :prioritized_client_columns, :text

    MatchRoutes::Base.preload(:match_prioritization).each do |route|  
      route.update(prioritized_client_columns: route.match_prioritization.class.supporting_column_names)  
    end  
  end
end
