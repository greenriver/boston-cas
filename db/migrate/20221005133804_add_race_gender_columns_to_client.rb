class AddRaceGenderColumnsToClient < ActiveRecord::Migration[6.0]
  def change
    add_column :project_clients, :am_ind_ak_native, :boolean, default: false
    add_column :project_clients, :asian, :boolean, default: false
    add_column :project_clients, :black_af_american, :boolean, default: false
    add_column :project_clients, :native_hi_pacific, :boolean, default: false
    add_column :project_clients, :white, :boolean, default: false

    add_column :clients, :am_ind_ak_native, :boolean, default: false
    add_column :clients, :asian, :boolean, default: false
    add_column :clients, :black_af_american, :boolean, default: false
    add_column :clients, :native_hi_pacific, :boolean, default: false
    add_column :clients, :white, :boolean, default: false

    add_column :project_clients, :female, :boolean, default: false
    add_column :project_clients, :male, :boolean, default: false
    add_column :project_clients, :no_single_gender, :boolean, default: false
    add_column :project_clients, :transgender, :boolean, default: false
    add_column :project_clients, :questioning, :boolean, default: false

    add_column :clients, :female, :boolean, default: false
    add_column :clients, :male, :boolean, default: false
    add_column :clients, :no_single_gender, :boolean, default: false
    add_column :clients, :transgender, :boolean, default: false
    add_column :clients, :questioning, :boolean, default: false
  end
end
