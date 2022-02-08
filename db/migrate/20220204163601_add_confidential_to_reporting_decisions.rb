class AddConfidentialToReportingDecisions < ActiveRecord::Migration[6.0]
  def change
    add_column :reporting_decisions, :confidential, :boolean, default: false
  end
end
