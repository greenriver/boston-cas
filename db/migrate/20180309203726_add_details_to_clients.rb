class AddDetailsToClients < ActiveRecord::Migration
  def change
    add_column :clients, :congregate_housing, :boolean, default: false
    add_column :clients, :sober_housing, :boolean, default: false
  end
end
