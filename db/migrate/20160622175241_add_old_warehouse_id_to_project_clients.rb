class AddOldWarehouseIdToProjectClients < ActiveRecord::Migration[4.2]
  def change
    add_column :project_clients, :old_warehouse_id, :string
  end
end
