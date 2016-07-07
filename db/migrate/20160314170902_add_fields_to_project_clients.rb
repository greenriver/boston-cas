class AddFieldsToProjectClients < ActiveRecord::Migration
  def change
    add_column :project_clients, :clientguid, :uuid
    add_column :project_clients, :middle_name, :string
    add_column :project_clients, :ssn_quality_code, :integer
    add_column :project_clients, :dob_quality_code, :integer
    add_column :project_clients, :primary_race, :string
    add_column :project_clients, :secondary_race, :string
    add_column :project_clients, :gender, :integer
    add_column :project_clients, :ethnicity, :integer
    add_column :project_clients, :disabling_condition, :integer
    # this comes directly from the HMIS
    add_column :project_clients, :hud_chronic_homelessness, :integer
    # this gets calculated on import based on various factors
    add_column :project_clients, :calculated_chronic_homelessness, :integer
    add_column :project_clients, :chronic_health_condition, :integer
    add_column :project_clients, :physical_disability, :integer
    add_column :project_clients, :hivaids_status, :integer
    add_column :project_clients, :mental_health_problem, :integer
    add_column :project_clients, :domestic_violence, :integer
  end
end
