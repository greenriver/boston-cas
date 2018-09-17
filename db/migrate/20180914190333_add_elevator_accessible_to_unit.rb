class AddElevatorAccessibleToUnit < ActiveRecord::Migration
  def change
    add_column :units, :elevator_accessible, :boolean, default: false, null: false
  end
end
