class AddDoToMatchContacts < ActiveRecord::Migration
  def change
    add_column :client_opportunity_match_contacts, :do, :boolean, default: false, null: false
    add_column :program_contacts, :do, :boolean, default: false, null: false
  end
end
