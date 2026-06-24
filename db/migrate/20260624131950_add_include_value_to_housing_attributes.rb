class AddIncludeValueToHousingAttributes < ActiveRecord::Migration[7.2]
  def change
    add_column :housing_attributes, :include_value, :boolean, default: true, null: false
  end
end
