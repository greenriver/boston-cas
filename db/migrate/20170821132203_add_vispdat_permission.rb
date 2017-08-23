class AddVispdatPermission < ActiveRecord::Migration
  def up
    Role.ensure_permissions_exist
  end
  
  def down
    remove_column :roles, :can_view_vspdats, :boolean
  end
end
