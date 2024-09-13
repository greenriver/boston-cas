class AddContactOrderToContacts < ActiveRecord::Migration[7.0]
  def change
    [
      :building_contacts,
      :client_opportunity_match_contacts,
      :opportunity_contacts,
      :subgrantee_contacts
    ].each do |table|
      add_column table, :contact_order, :integer
    end
  end
end
