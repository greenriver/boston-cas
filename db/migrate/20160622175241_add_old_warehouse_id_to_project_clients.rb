class AddOldWarehouseIdToProjectClients < ActiveRecord::Migration
  def change
    add_column :project_clients, :old_warehouse_id, :string
  end
end
