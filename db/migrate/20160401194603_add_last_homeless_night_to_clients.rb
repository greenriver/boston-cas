class AddLastHomelessNightToClients < ActiveRecord::Migration
  def change
    add_column :project_clients, :calculated_last_homeless_night, :date
  end
end
