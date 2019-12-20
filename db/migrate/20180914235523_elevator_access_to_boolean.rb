class ElevatorAccessToBoolean < ActiveRecord::Migration[4.2]
  def change
    remove_column :project_clients, :requires_elevator_access, :integer, default: 1
    remove_column :clients, :requires_elevator_access, :integer, default: 1
    add_column :project_clients, :requires_elevator_access, :boolean, default: false
    add_column :clients, :requires_elevator_access, :boolean, default: false

    remove_column :project_clients, :requires_ground_floor, :boolean, default: false
    remove_column :clients, :requires_ground_floor, :boolean, default: false
  end
end
