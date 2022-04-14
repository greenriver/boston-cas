class AddHmisDaysHomelessToProjectClients < ActiveRecord::Migration[6.0]
  def change
    [:project_clients, :clients].each do |table|
      add_column table, :hmis_days_homeless_all_time, :integer
      add_column table, :hmis_days_homeless_last_three_years, :integer
    end
  end
end
