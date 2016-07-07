class AddActiveToClientOpportunityMatches < ActiveRecord::Migration
  def change
    add_column :client_opportunity_matches, :active, :boolean, default: false, null: false
    add_index :client_opportunity_matches, :active
    add_column :client_opportunity_matches, :success, :boolean, default: false, null: false
    add_index :client_opportunity_matches, :success
  end
end
