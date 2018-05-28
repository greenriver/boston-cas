class AddAttributesToUnits < ActiveRecord::Migration
  def change
    add_column :units, :ground_floor, :boolean
    add_column :units, :wheelchair_accessible, :boolean
    add_column :units, :occupancy, :integer, default: 1
    add_column :units, :number_of_bedrooms, :integer
    add_column :units, :target_population, :string
  end
end
