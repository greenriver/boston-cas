class AddNeighborhoodInterestsToClient < ActiveRecord::Migration[4.2]
  def change
    add_column :clients, :neighborhood_interests, :jsonb, default: [], null: false
  end
end
