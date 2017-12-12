class AddMatchNotePermission < ActiveRecord::Migration
  def up
    Role.ensure_permissions_exist
  end
  
  def down
    remove_column :roles, :can_create_overall_note, :boolean, default: false
  end
end
