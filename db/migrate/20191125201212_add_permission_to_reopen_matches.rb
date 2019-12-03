class AddPermissionToReopenMatches < ActiveRecord::Migration
  def up
    Role.ensure_permissions_exist
  end

  def down
    remove_column :roles, :can_reopen_matches, :boolean
  end
end
