class AddDischargeTypeToProjectClients < ActiveRecord::Migration[4.2]
  def change
    add_column :project_clients, :discharge_type, :integer
    add_column :project_clients, :developmental_disability, :integer
  end
end
