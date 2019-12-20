class AddCasFlagsToClient < ActiveRecord::Migration[4.2]
  def change
    add_column :clients, :disability_verified_on, :datetime, index: true
    add_column :clients, :housing_assistance_network_released_on, :datetime, index: true
    add_column :clients, :sync_with_cas, :boolean, default: false, null: false, index: true
  end
end
