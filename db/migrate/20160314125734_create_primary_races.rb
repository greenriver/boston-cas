class CreatePrimaryRaces < ActiveRecord::Migration
  def change
    create_table :primary_races do |t|
      t.integer :numeric
      t.string :text

      t.timestamps null: false
    end
  end
end
