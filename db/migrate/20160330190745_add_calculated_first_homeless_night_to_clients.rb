class AddCalculatedFirstHomelessNightToClients < ActiveRecord::Migration
  def change
    add_column :clients, :calculated_first_homeless_night, :date
  end
end
