class AddVashEligible < ActiveRecord::Migration[4.2]
  def change
    add_column :project_clients, :vash_eligible, :boolean
    add_column :clients, :vash_eligible, :boolean
  end
end
