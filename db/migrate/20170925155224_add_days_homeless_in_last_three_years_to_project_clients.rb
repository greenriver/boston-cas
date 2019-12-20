class AddDaysHomelessInLastThreeYearsToProjectClients < ActiveRecord::Migration[4.2]
  def change
    add_column :project_clients, :days_homeless_in_last_three_years, :integer
    add_column :clients, :days_homeless_in_last_three_years, :integer
  end
end
