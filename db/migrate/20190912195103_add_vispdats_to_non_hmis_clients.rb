class AddVispdatsToNonHmisClients < ActiveRecord::Migration[4.2]
  def change
    add_column :non_hmis_clients, :vispdat_score, :integer, default: 0
    add_column :non_hmis_clients, :vispdat_priority_score, :integer, default: 0
  end
end
