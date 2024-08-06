class AddCanManageAllNonHmisClients < ActiveRecord::Migration[7.0]
  def up
    Role.ensure_permissions_exist
  end

  def down
    remove_column :roles, :can_manage_all_deidentified_clients, :boolean
    remove_column :roles, :can_manage_all_identified_clients, :boolean
  end
end
