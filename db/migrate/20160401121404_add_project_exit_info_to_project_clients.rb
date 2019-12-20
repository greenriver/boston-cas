class AddProjectExitInfoToProjectClients < ActiveRecord::Migration[4.2]
  def change
    add_column :project_clients, :project_exit_destination, :string
    add_column :project_clients, :project_exit_destination_specific, :string
    add_column :project_clients, :project_exit_destination_generic, :string
    add_column :project_clients, :project_exit_housing_disposition, :string
  end
end
