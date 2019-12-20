class RenameProjectOwnerFields < ActiveRecord::Migration[4.2]
  def change
    rename_column :projects, :project_owner_id, :subgrantee_id
  end
end
