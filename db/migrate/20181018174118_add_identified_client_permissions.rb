class AddIdentifiedClientPermissions < ActiveRecord::Migration
  def up
    Role.ensure_permissions_exist
  end
  
  def down
    remove_column :roles, :can_enter_identified_clients, :boolean
    remove_column :roles, :can_manage_identified_clients, :boolean
    remove_column :roles, :can_add_cohorts_to_identified_clients, :boolean
  end
end
