class AddTcHatAdditionalFields < ActiveRecord::Migration[6.0]
  def change
    [:project_clients, :clients].each do |table|
      add_column table, :drug_test, :boolean, default: false
      add_column table, :heavy_drug_use, :boolean, default: false
      add_column table, :sober, :boolean, default: false
      add_column table, :willing_case_management, :boolean, default: false
      add_column table, :employed_three_months, :boolean, default: false
      add_column table, :living_wage, :boolean, default: false
    end
  end
end
