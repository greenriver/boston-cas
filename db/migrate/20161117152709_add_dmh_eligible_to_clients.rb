class AddDmhEligibleToClients < ActiveRecord::Migration
  def change
    add_column :project_clients, :dmh_eligible, :boolean, default: false
    add_column :clients, :dmh_eligible, :boolean, default: false
  end
end
