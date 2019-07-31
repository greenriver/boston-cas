class AddNonHmisClientIdentifierToProjectClients < ActiveRecord::Migration
  def change
    add_column :project_clients, :non_hmis_client_identifier, :string
  end
end
