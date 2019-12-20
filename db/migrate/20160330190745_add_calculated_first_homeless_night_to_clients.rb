class AddCalculatedFirstHomelessNightToClients < ActiveRecord::Migration[4.2]
  def change
    add_column :clients, :calculated_first_homeless_night, :date
  end
end
