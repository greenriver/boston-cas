class CreatePrimaryRaces < ActiveRecord::Migration[4.2]
  def change
    create_table :primary_races do |t|
      t.integer :numeric
      t.string :text

      t.timestamps null: false
    end
  end
end
