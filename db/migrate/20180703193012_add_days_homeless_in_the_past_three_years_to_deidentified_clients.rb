class AddDaysHomelessInThePastThreeYearsToDeidentifiedClients < ActiveRecord::Migration[4.2]
  def change
    add_column :deidentified_clients, :days_homeless_in_the_last_three_years, :integer
  end
end
