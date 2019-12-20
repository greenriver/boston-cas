class AddUnitIdToOpportunities < ActiveRecord::Migration[4.2]
  def change
    add_reference :opportunities, :unit, index: true

    remove_column :opportunities, :type, :string
    remove_column :opportunities, :entity_id, :integer
    change_column_null :opportunities, :building_id, true
    change_column_null :opportunities, :name, true
  end
end
