class ReAddIncomeFieldsToClient < ActiveRecord::Migration[4.2]
  def change
    add_column :project_clients, :income_total_monthly, :float
    add_column :project_clients, :income_total_monthly_last_collected, :datetime
    add_column :clients, :income_total_monthly, :float
    add_column :clients, :income_total_monthly_last_collected, :datetime
  end
end
