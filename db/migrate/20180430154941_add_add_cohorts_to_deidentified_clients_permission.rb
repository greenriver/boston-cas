class AddAddCohortsToDeidentifiedClientsPermission < ActiveRecord::Migration
  def up
    Role.ensure_permissions_exist
  end
  
  def down
    remove_column :roles, :can_add_cohorts_to_deidentified_clients, :boolean
  end
end
