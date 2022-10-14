class AddRaceColumnsToNonHmisClient < ActiveRecord::Migration[6.0]
  def change
    add_column :non_hmis_clients, :am_ind_ak_native, :boolean, default: false
    add_column :non_hmis_clients, :asian, :boolean, default: false
    add_column :non_hmis_clients, :black_af_american, :boolean, default: false
    add_column :non_hmis_clients, :native_hi_pacific, :boolean, default: false
    add_column :non_hmis_clients, :white, :boolean, default: false

    add_column :non_hmis_clients, :female, :boolean, default: false
    add_column :non_hmis_clients, :male, :boolean, default: false
    add_column :non_hmis_clients, :no_single_gender, :boolean, default: false
    add_column :non_hmis_clients, :transgender, :boolean, default: false
    add_column :non_hmis_clients, :questioning, :boolean, default: false

    remove_column :non_hmis_clients, :race, :integer
    remove_column :non_hmis_clients, :gender, :integer
  end
end
