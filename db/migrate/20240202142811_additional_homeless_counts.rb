class AdditionalHomelessCounts < ActiveRecord::Migration[6.1]
  def change
    [
      :project_clients,
      :clients,
    ].each do |table|
      [
        :calculated_homeless_nights_sheltered,
        :calculated_homeless_nights_unsheltered,
        :total_homeless_nights_sheltered,
      ].each do |col|
        add_column table, col, :integer, default: 0
      end
    end
  end
end
