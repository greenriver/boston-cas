class CreateHasDevelopmentalDisabilities < ActiveRecord::Migration[4.2]
  def change
    create_table :has_developmental_disabilities do |t|
      t.integer :numeric
      t.string :text

      t.timestamps null: false
    end
  end
end
