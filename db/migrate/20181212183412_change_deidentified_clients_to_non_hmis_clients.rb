class ChangeDeidentifiedClientsToNonHmisClients < ActiveRecord::Migration
  def change
    rename_table :deidentified_clients, :non_hmis_clients

    add_column :non_hmis_clients, :type, :string
    NonHmisClient.all.each do | client |
      if client.identified
        client.update_columns(type: :IdentifiedClient)
      else
        client.update_columns(type: :DeidentifiedClient)
      end
    end
  end
end
