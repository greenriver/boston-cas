class AddDefaultsToBooleanColumnsInClients < ActiveRecord::Migration
  def change
    change_column :clients, :veteran, :boolean, default: false
    Client.where(veteran: nil).update_all(veteran: false)
    change_column :clients, :chronic_homeless, :boolean, default: false
    Client.where(chronic_homeless: nil).update_all(chronic_homeless: false)
  end
end
