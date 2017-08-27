class AddHspToMatchContacts < ActiveRecord::Migration
  def change
    add_column :client_opportunity_match_contacts, :hsp, :boolean, null: false, default: false
  end
end
