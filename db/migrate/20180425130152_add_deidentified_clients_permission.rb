class AddDeidentifiedClientsPermission < ActiveRecord::Migration[4.2]
  def up
    Role.ensure_permissions_exist
  end
  
  def down
    remove_column :roles, :can_enter_deidentified_clients, :boolean
    remove_column :roles, :can_manage_deidentified_clients, :boolean
  end
end
