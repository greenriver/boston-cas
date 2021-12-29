class AddStrengths < ActiveRecord::Migration[6.0]
  def change
    [:project_clients, :clients].each do |table|
      add_column table, :strengths, :jsonb, default: []
      add_column table, :challenges, :jsonb, default: []
      add_column table, :foster_care, :boolean, default: false
      add_column table, :open_case, :boolean, default: false
      add_column table, :housing_for_formerly_homeless, :boolean, default: false
    end
  end
end
