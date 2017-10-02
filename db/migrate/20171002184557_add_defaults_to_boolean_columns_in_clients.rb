class AddDefaultsToBooleanColumnsInClients < ActiveRecord::Migration
  def change
    change_column :clients, :veteran, :boolean, default: false
    change_column :clients, :chronic_homeless, :boolean, default: false
  end
end
