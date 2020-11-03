class AddHudFieldsToCovidPathways < ActiveRecord::Migration[6.0]
  def change
    add_column :non_hmis_clients, :race, :integer
    add_column :non_hmis_clients, :ethnicity, :integer
  end
end
