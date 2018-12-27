class AddNeighborhoodInterestsToProjectClient < ActiveRecord::Migration
  def change
    add_column :project_clients, :neighborhood_interests, :jsonb, default: [], null: false
  end
end
