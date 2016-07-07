class CreateDomesticViolenceSurvivors < ActiveRecord::Migration
  def change
    create_table :domestic_violence_survivors do |t|
      t.integer :numeric
      t.string :text

      t.timestamps null: false
    end
  end
end
