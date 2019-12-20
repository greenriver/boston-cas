class AddAvailableToClients < ActiveRecord::Migration[4.2]
  def change
    add_column :clients, :available, :boolean, null: false, default: true
  end
end
