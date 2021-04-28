class CreateUnitAttributes < ActiveRecord::Migration[6.0]
  def change
    create_table :unit_attributes do |t|
      t.references :unit
      t.string :name
      t.string :value

      t.timestamps
      t.datetime :deleted_at
    end
  end
end
