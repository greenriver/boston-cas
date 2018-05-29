class AddDaysLiterallyHomelessToClients < ActiveRecord::Migration
  def change
    add_column :project_clients, :days_literally_homeless_in_last_three_years, :integer, default: 0
    add_column :clients, :days_literally_homeless_in_last_three_years, :integer, default: 0
  end
end
