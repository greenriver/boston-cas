class AddWarehouseIneligibleToMatchDecisionReasons < ActiveRecord::Migration[6.0]
  def change
    add_column :match_decision_reasons, :ineligible_in_warehouse, :boolean, default: false, null: false
  end
end
