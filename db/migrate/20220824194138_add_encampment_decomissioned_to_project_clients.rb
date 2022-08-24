class AddEncampmentDecomissionedToProjectClients < ActiveRecord::Migration[6.0]
  def change
    add_column :project_clients, :encampment_decomissioned, :boolean, default: false
  end
end
