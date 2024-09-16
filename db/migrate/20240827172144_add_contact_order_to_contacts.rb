class AddContactOrderToContacts < ActiveRecord::Migration[7.0]
  def change
    add_column :client_opportunity_match_contacts, :contact_order, :integer
  end
end
