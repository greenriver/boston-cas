class AddMatchGroup < ActiveRecord::Migration[6.0]
  def change
    [:project_clients, :clients].each do |table|
      add_column table, :match_group, :integer
    end
  end
end
