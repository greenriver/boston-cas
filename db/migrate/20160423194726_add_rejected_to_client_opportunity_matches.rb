class AddRejectedToClientOpportunityMatches < ActiveRecord::Migration[4.2]
  def change
    add_column :client_opportunity_matches, :rejected, :boolean, default: false, null: false
    add_index :client_opportunity_matches, :rejected
  end
end
