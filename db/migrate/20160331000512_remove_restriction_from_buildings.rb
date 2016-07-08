class RemoveRestrictionFromBuildings < ActiveRecord::Migration
  def change
    change_column_null :buildings, :building_type, true
    change_column_null :buildings, :subgrantee_id, true
  end
end
