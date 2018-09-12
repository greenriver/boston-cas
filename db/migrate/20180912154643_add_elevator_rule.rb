class AddElevatorRule < ActiveRecord::Migration
  def change
    add_column :project_clients, :requires_elevator_access, :integer, default: 1
    add_column :clients, :requires_elevator_access, :integer, default: 1
  end
end
