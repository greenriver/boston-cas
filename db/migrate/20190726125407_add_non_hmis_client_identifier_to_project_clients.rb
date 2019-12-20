class AddNonHmisClientIdentifierToProjectClients < ActiveRecord::Migration[4.2]
  def change
    add_column :project_clients, :non_hmis_client_identifier, :string
  end
end
