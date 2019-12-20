class AddVispdatDaysHomelessToClients < ActiveRecord::Migration[4.2]
  def change
    add_column :clients, :vispdat_length_homeless_in_days, :integer, null: false, default: 0
  end
end
