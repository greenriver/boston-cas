class AddDaysHomelessInThePastThreeYearsToDeidentifiedClients < ActiveRecord::Migration
  def change
    add_column :deidentified_clients, :days_homeless_in_the_last_three_years, :integer
  end
end
