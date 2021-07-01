class AddCanManageSessionsPermission < ActiveRecord::Migration[6.0]
  def up
    Role.ensure_permissions_exist
  end

  def down
    remove_column :roles, :can_manage_sessions, :boolean, default: false
  end
end
