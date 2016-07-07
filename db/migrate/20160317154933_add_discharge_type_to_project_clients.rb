class AddDischargeTypeToProjectClients < ActiveRecord::Migration
  def change
    add_column :project_clients, :discharge_type, :integer
    add_column :project_clients, :developmental_disability, :integer
  end
end
