class AddVispdatDaysHomelessToClients < ActiveRecord::Migration
  def change
    add_column :clients, :vispdat_length_homeless_in_days, :integer, null: false, default: 0
  end
end
