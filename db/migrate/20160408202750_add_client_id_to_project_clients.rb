class AddClientIdToProjectClients < ActiveRecord::Migration[4.2]
  def change
    add_reference :project_clients, :client, index: true
    remove_column :clients, :clientguid, :uuid
  end
end
