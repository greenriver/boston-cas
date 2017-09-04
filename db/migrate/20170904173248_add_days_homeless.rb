class AddDaysHomeless < ActiveRecord::Migration
  def change
    [:clients, :project_clients].each do |table|
      add_column table, :days_homeless, :integer
    end
  end
end
