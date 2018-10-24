class AddStalledInfoToMatch < ActiveRecord::Migration
  def change
    add_column :client_opportunity_matches, :stall_date, :date
    add_column :client_opportunity_matches, :stall_contacts_notified, :datetime
    add_column :client_opportunity_matches, :dnd_notified, :datetime
  end
end
