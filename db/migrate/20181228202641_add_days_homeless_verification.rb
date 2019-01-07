class AddDaysHomelessVerification < ActiveRecord::Migration
  def change
    add_column :non_hmis_clients, :date_days_homeless_verified, :date
    add_column :non_hmis_clients, :who_verified_days_homeless, :string

    add_column :project_clients, :date_days_homeless_verified, :date
    add_column :project_clients, :who_verified_days_homeless, :string

    add_column :clients, :date_days_homeless_verified, :date
    add_column :clients, :who_verified_days_homeless, :string
  end
end
