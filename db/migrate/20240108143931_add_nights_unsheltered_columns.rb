class AddNightsUnshelteredColumns < ActiveRecord::Migration[6.1]
  def change
    [:project_clients, :clients].each do |table|
      add_column table, :additional_homeless_nights_sheltered, :integer, default: 0
      add_column table, :additional_homeless_nights_unsheltered, :integer, default: 0
      add_column table, :total_homeless_nights_unsheltered, :integer, default: 0
    end
  end
end
