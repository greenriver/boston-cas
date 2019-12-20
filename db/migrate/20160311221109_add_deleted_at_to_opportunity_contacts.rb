class AddDeletedAtToOpportunityContacts < ActiveRecord::Migration[4.2]
  def change
    add_column :opportunity_contacts, :deleted_at, :datetime
    add_index :opportunity_contacts, :deleted_at
  end
end
