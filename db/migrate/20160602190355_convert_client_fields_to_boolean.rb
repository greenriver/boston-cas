class ConvertClientFieldsToBoolean < ActiveRecord::Migration[4.2]
  def change
    remove_column :clients, :hiv_aids, :integer
    remove_column :clients, :chronic_health_problem, :integer
    remove_column :clients, :mental_health_problem, :integer
    remove_column :clients, :substance_abuse_problem, :integer
    remove_column :clients, :physical_disability, :integer
    remove_column :clients, :disabling_condition, :integer

    add_column :clients, :hiv_aids, :boolean, default: false
    add_column :clients, :chronic_health_problem, :boolean, default: false
    add_column :clients, :mental_health_problem, :boolean, default: false
    add_column :clients, :substance_abuse_problem, :boolean, default: false
    add_column :clients, :physical_disability, :boolean, default: false
    add_column :clients, :disabling_condition, :boolean, default: false

  end
end
