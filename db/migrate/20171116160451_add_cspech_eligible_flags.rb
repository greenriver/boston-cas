class AddCspechEligibleFlags < ActiveRecord::Migration[4.2]
  def change
    add_column :project_clients, :cspech_eligible, :boolean, default: false
    add_column :clients, :cspech_eligible, :boolean, default: false
  end
end
