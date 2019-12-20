class AddInvalidatedToClientOpportunityMatches < ActiveRecord::Migration[4.2]
  def change
    add_column :client_opportunity_matches, :invalid, :boolean
    add_index :client_opportunity_matches, :invalid
  end
end
