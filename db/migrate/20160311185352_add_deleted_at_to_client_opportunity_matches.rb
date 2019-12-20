class AddDeletedAtToClientOpportunityMatches < ActiveRecord::Migration[4.2]
  def change
    add_column :client_opportunity_matches, :deleted_at, :datetime
    add_index :client_opportunity_matches, :deleted_at, where: "deleted_at IS NULL"
  end
end
