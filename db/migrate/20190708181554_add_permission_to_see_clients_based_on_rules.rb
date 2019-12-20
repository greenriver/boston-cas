class AddPermissionToSeeClientsBasedOnRules < ActiveRecord::Migration[4.2]
  def up
    Role.ensure_permissions_exist
  end

  def down
    remove_column :roles, :can_edit_clients_based_on_rules, :boolean
  end
end
