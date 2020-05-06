class AddHealthPrioritizedToClients < ActiveRecord::Migration[6.0]
  def change
    add_column :project_clients, :health_prioritized, :boolean, default: false
    add_column :clients, :health_prioritized, :boolean, default: false
  end
end
