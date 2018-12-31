class AddAvailableToNonHmisClients < ActiveRecord::Migration
  def change
    add_column :non_hmis_clients, :available, :boolean, default: true, null: false
  end
end
