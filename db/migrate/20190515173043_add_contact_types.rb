class AddContactTypes < ActiveRecord::Migration
  def change
    add_column :client_contacts, :dnd_staff, :boolean, null: false, default: false
    add_column :client_contacts, :housing_subsidy_admin, :boolean, null: false, default: false
    add_column :client_contacts, :ssp, :boolean, null: false, default: false
    add_column :client_contacts, :hsp, :boolean, null: false, default: false
    add_column :client_contacts, :do, :boolean, null: false, default: false
  end
end