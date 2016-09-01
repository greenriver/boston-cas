class AddUniverseStateToClientOpportunityMatches < ActiveRecord::Migration
  def change
    add_column :client_opportunity_matches, :universe_state, :json
  end
end
