class AddAddCohortsToDeidentifiedClientsPermission < ActiveRecord::Migration[4.2]
  def up
    Role.ensure_permissions_exist
  end
  
  def down
    remove_column :roles, :can_add_cohorts_to_deidentified_clients, :boolean
  end
end
