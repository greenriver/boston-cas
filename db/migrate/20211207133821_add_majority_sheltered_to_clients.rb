class AddMajorityShelteredToClients < ActiveRecord::Migration[6.0]
  def change
    add_column :clients, :majority_sheltered, :boolean, default: false
    add_column :project_clients, :majority_sheltered, :boolean, default: false
  end
end
