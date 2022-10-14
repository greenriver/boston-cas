class AddActiveColumnToUnits < ActiveRecord::Migration[6.0]
  def change
    add_column :units, :active, :boolean, default: true, null: false
  end
end
