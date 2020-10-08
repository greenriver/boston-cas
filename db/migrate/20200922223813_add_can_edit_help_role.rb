class AddCanEditHelpRole < ActiveRecord::Migration[6.0]
  def change
    add_column :roles, :can_edit_help, :boolean, default: false
  end
end
