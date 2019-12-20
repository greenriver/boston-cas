class AddDetailsToClients < ActiveRecord::Migration[4.2]
  def change
    add_column :clients, :congregate_housing, :boolean, default: false
    add_column :clients, :sober_housing, :boolean, default: false
  end
end
