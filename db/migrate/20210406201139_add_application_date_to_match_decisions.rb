class AddApplicationDateToMatchDecisions < ActiveRecord::Migration[6.0]
  def change
    add_column :match_decisions, :application_date, :date
  end
end
