class RelaxNonNullConstraintOnNeighborhoodInterests < ActiveRecord::Migration
  def up
    change_column :non_hmis_clients, :neighborhood_interests, :json, null: true
  end
  def down
    # Not implemented
  end
end
