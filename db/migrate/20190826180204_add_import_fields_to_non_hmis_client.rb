class AddImportFieldsToNonHmisClient < ActiveRecord::Migration[4.2]
  def change
    add_column :non_hmis_clients, :chronic_health_condition, :boolean
    add_column :non_hmis_clients, :mental_health_problem, :boolean
    add_column :non_hmis_clients, :substance_abuse_problem, :boolean
  end
end
