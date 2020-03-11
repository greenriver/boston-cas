class AddDvrrhFields < ActiveRecord::Migration[6.0]
  def change
    # remove some unused pathways columns
    remove_column :project_clients, :pathways_domestic_violence, :boolean, default: false, null: false
    remove_column :clients, :pathways_domestic_violence, :boolean, default: false, null: false

    remove_column :project_clients, :pathways_other_accessibility, :boolean, default: false
    remove_column :clients, :pathways_other_accessibility, :boolean, default: false

    remove_column :project_clients, :pathways_disabled_housing, :boolean, default: false
    remove_column :clients, :pathways_disabled_housing, :boolean, default: false

    add_column :project_clients, :dv_rrh_desired, :boolean, default: false
    add_column :clients, :dv_rrh_desired, :boolean, default: false
  end
end
