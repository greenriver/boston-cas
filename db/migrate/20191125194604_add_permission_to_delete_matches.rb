class AddPermissionToDeleteMatches < ActiveRecord::Migration[4.2]
  def up
    Role.ensure_permissions_exist
  end

  def down
    remove_column :roles, :can_delete_matches, :boolean
  end
end
