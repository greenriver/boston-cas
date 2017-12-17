class AddCalculatedLastHomelessNightToClients < ActiveRecord::Migration
  def change
    add_column :clients, :calculated_last_homeless_night, :date
  end
end
