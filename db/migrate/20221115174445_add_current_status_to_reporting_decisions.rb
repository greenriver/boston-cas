class AddCurrentStatusToReportingDecisions < ActiveRecord::Migration[6.0]
  def change
    add_column :reporting_decisions, :current_status, :string
    add_column :reporting_decisions, :step_tag, :string
  end
end
