class AddDeleteClientNotesPermission < ActiveRecord::Migration
  def up
    Role.ensure_permissions_exist
  end
  
  def down
    remove_column :roles, :can_delete_client_notes, :boolean, default: false
  end
end
