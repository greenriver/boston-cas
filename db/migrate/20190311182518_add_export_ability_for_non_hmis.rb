class AddExportAbilityForNonHmis < ActiveRecord::Migration
  def up
    Role.ensure_permissions_exist
  end
  
  def down
    remove_column :roles, :can_export_deidentified_clients, :boolean
    remove_column :roles, :can_export_identified_clients, :boolean
  end
end
