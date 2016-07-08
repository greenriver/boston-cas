class AddAdminAndDndStaffToUsers < ActiveRecord::Migration
  def change
    add_column :users, :admin, :boolean, null: false, default: false
    add_column :users, :dnd_staff, :boolean, null: false, default: false
  end
end
