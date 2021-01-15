class AddCanAuditUserToRoles < ActiveRecord::Migration[6.0]
  def up
    Role.ensure_permissions_exist
    Role.reset_column_information
  end

  def down
    remove_column :roles, :can_audit_users
  end
end
