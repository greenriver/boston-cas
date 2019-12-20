class AddNeighborhoodInterestsToProjectClient < ActiveRecord::Migration[4.2]
  def change
    add_column :project_clients, :neighborhood_interests, :jsonb, default: [], null: false
  end
end
