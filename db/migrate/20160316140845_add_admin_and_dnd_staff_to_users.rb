class AddAdminAndDndStaffToUsers < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :admin, :boolean, null: false, default: false
    add_column :users, :dnd_staff, :boolean, null: false, default: false
  end
end
