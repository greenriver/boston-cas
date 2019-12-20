class MoveAddressFromUnitToBuilding < ActiveRecord::Migration[4.2]
  def change
    remove_column :units, :address, :string
    remove_column :units, :city, :string
    remove_column :units, :state, :string
    remove_column :units, :zip_code, :string
    remove_column :units, :geo_code, :string

    add_column :buildings, :address, :string
    add_column :buildings, :city, :string
    add_column :buildings, :state, :string
    add_column :buildings, :zip_code, :string
    add_column :buildings, :geo_code, :string
  end
end
