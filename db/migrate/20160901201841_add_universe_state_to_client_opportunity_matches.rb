class AddUniverseStateToClientOpportunityMatches < ActiveRecord::Migration[4.2]
  def change
    add_column :client_opportunity_matches, :universe_state, :json
  end
end
