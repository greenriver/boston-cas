class RenameProjectOwnerFields < ActiveRecord::Migration
  def change
    rename_column :projects, :project_owner_id, :subgrantee_id
  end
end
