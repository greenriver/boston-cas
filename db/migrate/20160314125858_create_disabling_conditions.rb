class CreateDisablingConditions < ActiveRecord::Migration
  def change
    create_table :disabling_conditions do |t|
      t.integer :numeric
      t.string :text

      t.timestamps null: false
    end
  end
end
