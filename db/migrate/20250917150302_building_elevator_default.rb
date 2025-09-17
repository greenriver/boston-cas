class BuildingElevatorDefault < ActiveRecord::Migration[7.2]
  def change
    add_column :buildings, :elevator_accessible_default, :boolean, default: false
  end
end
