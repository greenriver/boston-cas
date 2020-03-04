class AddDecisionIneligibleToCasReports < ActiveRecord::Migration[6.0]
  def change
    add_column :reporting_decisions, :ineligible_in_warehouse, :boolean, default: false, null: false, index: true
  end
end
