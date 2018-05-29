class AddUnitRequirementsToClients < ActiveRecord::Migration
  def change
    add_column :clients, :requires_ground_floor, :boolean, default: false, null: false
    add_column :clients, :requires_wheelchair_accessibility, :boolean, default: false, null: false
    add_column :clients, :required_number_of_bedrooms, :integer, default: 1, null: false
  end
end
