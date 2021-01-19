class AddCanEditHelpRole < ActiveRecord::Migration[6.0]
  def up
    Role.ensure_permissions_exist
    Role.reset_column_information
  end
  
  def down
    remove_column :roles, :can_edit_help, :boolean, default: false
  end
end
