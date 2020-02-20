class AddIsCurrentlyYouthToNonHmisClients < ActiveRecord::Migration[6.0]
  def change
    add_column :non_hmis_clients, :is_currently_youth, :boolean, default: false, null: false
  end
end
