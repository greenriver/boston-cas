class AddAdditionalUnitAttributes < ActiveRecord::Migration
  def change
    add_column :units, :ground_floor, :boolean, default: false, null: false
    add_column :units, :wheelchair_accessible, :boolean, default: false, null: false
    add_column :units, :occupancy, :integer, default: 0, null: false
    add_column :units, :household_with_children, :boolean, default: false, null: false
    add_column :units, :number_of_bedrooms, :integer, default: 1, null: false
    add_column :units, :target_population, :string
  end
end
