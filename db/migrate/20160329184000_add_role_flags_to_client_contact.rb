class AddRoleFlagsToClientContact < ActiveRecord::Migration[4.2]
  def change
    add_column :client_contacts, :shelter_agency, :boolean, default: false, null: false
    add_column :client_contacts, :regular, :boolean, default: false, null: false
  end
end
