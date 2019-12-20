class AddSspToMatchContacts < ActiveRecord::Migration[4.2]
  def change
    add_column :client_opportunity_match_contacts, :ssp, :boolean, null: false, default: false
  end
end
