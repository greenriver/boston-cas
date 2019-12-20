class AddNeighborhoodInterestsToNonHmisClients < ActiveRecord::Migration[4.2]
  def change
    add_column :non_hmis_clients, :neighborhood_interests, :jsonb, default: [], null: false
  end
end
