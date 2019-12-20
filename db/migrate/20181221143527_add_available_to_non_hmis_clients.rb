class AddAvailableToNonHmisClients < ActiveRecord::Migration[4.2]
  def change
    add_column :non_hmis_clients, :available, :boolean, default: true, null: false
  end
end
