class AddChronicColumnsToProjectClients < ActiveRecord::Migration[4.2]
  def change
    add_column :project_clients, :calculated_bed_nights_in_last_three_years, :integer
    add_column :project_clients, :calculated_episodes_in_last_three_years, :integer
    add_column :project_clients, :calculated_months_continously_homeless_in_last_three_years, :integer
    add_column :project_clients, :calculated_first_homeless_night, :date
    add_column :project_clients, :reported_episodes_in_last_three_years, :string
    add_column :project_clients, :reported_continuously_homeless_for_last_year, :string
    add_column :project_clients, :reported_months_homeless_in_last_three_years, :string
    add_column :project_clients, :reported_months_continuously_homeless_immediately_prior, :string
    add_column :project_clients, :reported_months_continuously_homeless_documented, :string

  end
end
