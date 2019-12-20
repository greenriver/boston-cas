class AdditionalDeidentifiedFields < ActiveRecord::Migration[4.2]
  def change
    add_column :deidentified_clients, :requires_wheelchair_accessibility, :boolean, default: false, null: false
    add_column :deidentified_clients, :required_number_of_bedrooms, :integer, default: 1
    add_column :deidentified_clients, :required_minimum_occupancy, :integer, default: 1
    add_column :deidentified_clients, :requires_elevator_access, :boolean, default: false, null: false
  end
end
