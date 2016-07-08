class AddDeletedAtToClientOpportunityMatches < ActiveRecord::Migration
  def change
    add_column :client_opportunity_matches, :deleted_at, :datetime
    add_index :client_opportunity_matches, :deleted_at, where: "deleted_at IS NULL"
  end
end
