class CreatePhysicalDisabilities < ActiveRecord::Migration
  def change
    create_table :physical_disabilities do |t|
      t.integer :numeric
      t.string :text

      t.timestamps null: false
    end
  end
end
