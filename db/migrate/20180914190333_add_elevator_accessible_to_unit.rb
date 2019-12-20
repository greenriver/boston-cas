class AddElevatorAccessibleToUnit < ActiveRecord::Migration[4.2]
  def change
    add_column :units, :elevator_accessible, :boolean, default: false, null: false
  end
end
