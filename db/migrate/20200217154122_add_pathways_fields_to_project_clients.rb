class AddPathwaysFieldsToProjectClients < ActiveRecord::Migration[6.0]
  def change
    add_column :project_clients, :income_maximization_assistance_requested, :boolean, default: false
    add_column :clients, :income_maximization_assistance_requested, :boolean, default: false

    add_column :project_clients, :pending_subsidized_housing_placement, :boolean, default: false
    add_column :clients, :pending_subsidized_housing_placement, :boolean, default: false

    add_column :project_clients, :pathways_domestic_violence, :boolean, default: false
    add_column :clients, :pathways_domestic_violence, :boolean, default: false

    add_column :project_clients, :rrh_th_desired, :boolean, default: false
    add_column :clients, :rrh_th_desired, :boolean, default: false

    add_column :project_clients, :sro_ok, :boolean, default: false
    add_column :clients, :sro_ok, :boolean, default: false

    add_column :project_clients, :pathways_other_accessibility, :boolean, default: false
    add_column :clients, :pathways_other_accessibility, :boolean, default: false

    add_column :project_clients, :pathways_disabled_housing, :boolean, default: false
    add_column :clients, :pathways_disabled_housing, :boolean, default: false

    add_column :project_clients, :evicted, :boolean, default: false
    add_column :clients, :evicted, :boolean, default: false

  end
end
