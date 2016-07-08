class ClientColumnAdjustments < ActiveRecord::Migration
  def change
    add_column :clients, :clientguid, :uuid
    add_column :clients, :deleted_at, :datetime
    add_column :clients, :merged_into, :integer
    add_column :clients, :split_from, :integer

    add_index :clients, :deleted_at

    remove_column :clients, :ssn_quality
    remove_column :clients, :date_of_birth_quality
    remove_column :clients, :race
    remove_column :clients, :ethnicity
    remove_column :clients, :gender
    remove_column :clients, :veteran_status
    remove_column :clients, :hiv_aids
    remove_column :clients, :physical_disability
    remove_column :clients, :developmental_disability
    remove_column :clients, :cronic_health_problem
    remove_column :clients, :mental_health_problem
    remove_column :clients, :substance_abuse_problem
    remove_column :clients, :domestic_violence

    add_column :clients, :ssn_quality, :integer
    add_column :clients, :date_of_birth_quality, :integer
    add_column :clients, :race, :integer
    add_column :clients, :ethnicity, :integer
    add_column :clients, :gender, :integer
    add_column :clients, :veteran_status, :integer
    add_column :clients, :hiv_aids, :integer
    add_column :clients, :physical_disability, :integer
    add_column :clients, :developmental_disability, :integer
    add_column :clients, :cronic_health_problem, :integer
    add_column :clients, :mental_health_problem, :integer
    add_column :clients, :substance_abuse_problem, :integer
    add_column :clients, :domestic_violence, :integer
  end
end
