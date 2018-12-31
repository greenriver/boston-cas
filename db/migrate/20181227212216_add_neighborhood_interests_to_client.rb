class AddNeighborhoodInterestsToClient < ActiveRecord::Migration
  def change
    add_column :clients, :neighborhood_interests, :jsonb, default: [], null: false
  end
end
