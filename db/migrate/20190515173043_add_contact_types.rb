class AddContactTypes < ActiveRecord::Migration
  def up
    add_column :client_contacts, :dnd_staff, :boolean, null: false, default: false
    add_column :client_contacts, :housing_subsidy_admin, :boolean, null: false, default: false
    add_column :client_contacts, :ssp, :boolean, null: false, default: false
    add_column :client_contacts, :hsp, :boolean, null: false, default: false
    add_column :client_contacts, :do, :boolean, null: false, default: false
  end

  def down
    remove_column :client_contacts, :dnd_staff
    remove_column :client_contacts, :housing_subsidy_admin
    remove_column :client_contacts, :ssp
    remove_column :client_contacts, :hsp
    remove_column :client_contacts, :do
  end

end
