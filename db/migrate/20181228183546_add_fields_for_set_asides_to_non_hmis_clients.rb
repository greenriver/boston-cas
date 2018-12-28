class AddFieldsForSetAsidesToNonHmisClients < ActiveRecord::Migration
  def change
    add_column :non_hmis_clients, :income_total_monthly, :float
    add_column :non_hmis_clients, :disabling_condition, :boolean, default: false
    add_column :non_hmis_clients, :physical_disability, :boolean, default: false
    add_column :non_hmis_clients, :developmental_disability, :boolean, default: false
  end
end
