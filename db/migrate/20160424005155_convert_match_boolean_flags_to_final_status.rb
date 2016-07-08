class ConvertMatchBooleanFlagsToFinalStatus < ActiveRecord::Migration
  def change
    remove_column :client_opportunity_matches, :success
    remove_column :client_opportunity_matches, :rejected
    remove_column :client_opportunity_matches, :invalid
    
    add_column :client_opportunity_matches, :closed, :boolean
    add_index :client_opportunity_matches, :closed
    
    add_column :client_opportunity_matches, :closed_reason, :string
    add_index :client_opportunity_matches, :closed_reason
  end
end
