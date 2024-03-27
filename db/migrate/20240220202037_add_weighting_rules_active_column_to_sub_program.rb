class AddWeightingRulesActiveColumnToSubProgram < ActiveRecord::Migration[6.1]
  def change
    add_column :sub_programs, :weighting_rules_active, :boolean, default: true
  end
end
