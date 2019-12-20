class AddDetailsToProjectClients < ActiveRecord::Migration[4.2]
  def change
    add_column :project_clients, :congregate_housing, :boolean, default: false
    add_column :project_clients, :sober_housing, :boolean, default: false
  end
end
