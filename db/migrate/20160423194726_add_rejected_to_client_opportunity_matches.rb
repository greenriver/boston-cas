class AddRejectedToClientOpportunityMatches < ActiveRecord::Migration
  def change
    add_column :client_opportunity_matches, :rejected, :boolean, default: false, null: false
    add_index :client_opportunity_matches, :rejected
  end
end
