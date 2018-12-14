class ChangeDeidentifiedClientsToNonHmisClients < ActiveRecord::Migration
  def change
    rename_table :deidentified_clients, :non_hmis_clients

    add_column :non_hmis_clients, :type, :string
  end
end
