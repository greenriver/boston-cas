class AddSspToMatchContacts < ActiveRecord::Migration
  def change
    add_column :client_opportunity_match_contacts, :ssp, :boolean, null: false, default: false
  end
end
