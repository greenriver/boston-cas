class DropRaceGenderTables < ActiveRecord::Migration[6.0]
  def change
    drop_table :primary_races do |t|
      t.integer :numeric
      t.string :text
      t.timestamps null: false
    end

    drop_table :secondary_races do |t|
      t.integer :numeric
      t.string :text
      t.timestamps null: false
    end

    drop_table :genders do |t|
      t.integer :numeric
      t.string :text
      t.timestamps null: false
    end
  end
end
