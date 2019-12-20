class RenameProjectOwnersToSubgrantees < ActiveRecord::Migration[4.2]
  def change
    rename_table :project_owners, :subgrantees
    rename_column :project_owner_contacts, :project_owner_id, :subgrantee_id
    rename_table :project_owner_contacts, :subgrantee_contacts 
  end
end
