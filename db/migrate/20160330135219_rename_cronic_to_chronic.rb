class RenameCronicToChronic < ActiveRecord::Migration
  def change
    rename_column :clients, :cronic_homeless, :chronic_homeless
    rename_column :clients, :cronic_health_problem, :chronic_health_problem
  end
end
