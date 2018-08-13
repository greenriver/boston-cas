class AddUnitRequirementsToClient < ActiveRecord::Migration
  def change
    add_column :clients, :requires_ground_floor, :boolean, null: false, default: false
    add_column :clients, :requires_wheelchair_accessibility, :boolean, null: false, default: false
    add_column :clients, :required_number_of_bedrooms, :integer, null: false, default: 1

    add_column :project_clients, :requires_ground_floor, :boolean, null: false, default: false
    add_column :project_clients, :requires_wheelchair_accessibility, :boolean, null: false, default: false
    add_column :project_clients, :required_number_of_bedrooms, :integer, null: false, default: 1
  end
end
