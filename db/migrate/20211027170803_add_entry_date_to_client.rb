class AddEntryDateToClient < ActiveRecord::Migration[6.0]
  def change
    add_column :clients, :entry_date, :date
    add_column :project_clients, :financial_assistance_end_date, :date
    add_column :clients, :financial_assistance_end_date, :date
  end
end
