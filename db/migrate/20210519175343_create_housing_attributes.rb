class CreateHousingAttributes < ActiveRecord::Migration[6.0]
  def change
    create_table :housing_attributes do |t|
      t.references :housingable, polymorphic: true
      t.string :name
      t.string :value

      t.datetime :deleted_at
      t.timestamps
    end
  end
end
