class AddAvailableToClients < ActiveRecord::Migration
  def change
    add_column :clients, :available, :boolean, null: false, default: true
  end
end
