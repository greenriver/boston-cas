class AddActiveCohortIdsToClients < ActiveRecord::Migration[4.2]
  def change
    add_column :project_clients, :active_cohort_ids, :jsonb
    add_column :clients, :active_cohort_ids, :jsonb
  end
end
