class AddCanAuditUserToRoles < ActiveRecord::Migration[6.0]
  def change
    add_column :roles, :can_audit_users, :boolean, default: false
  end
end
