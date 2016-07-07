class AddClientIdToProjectClients < ActiveRecord::Migration
  def change
    add_reference :project_clients, :client, index: true
    remove_column :clients, :clientguid, :uuid
  end
end
