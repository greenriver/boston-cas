class AddColumnsToProjectClients < ActiveRecord::Migration[4.2]
  def change
    add_column :project_clients, :income_total_monthly, :float
    add_column :project_clients, :income_total_monthly_last_collected, :datetime
    add_column :project_clients, :us_citizen, :boolean
    add_column :project_clients, :assylee, :boolean
    add_column :project_clients, :lifetime_sex_offender, :boolean
    add_column :project_clients, :on_parole, :boolean
    add_column :project_clients, :on_parole_end_date, :date
    add_column :project_clients, :on_probation, :boolean
    add_column :project_clients, :on_probation_end_date, :date
    add_column :project_clients, :meth_production_conviction, :boolean
    add_column :project_clients, :clid, :integer

    remove_column :project_clients, :project_id, :integer
    remove_column :project_clients, :client_id, :integer
    remove_column :project_clients, :data_source_id, :integer

    add_column :project_clients, :data_source_id, :string

  end
end
