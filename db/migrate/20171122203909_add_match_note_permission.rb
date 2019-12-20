class AddMatchNotePermission < ActiveRecord::Migration[4.2]
  def up
    Role.ensure_permissions_exist
  end
  
  def down
    remove_column :roles, :can_create_overall_note, :boolean, default: false
  end
end
