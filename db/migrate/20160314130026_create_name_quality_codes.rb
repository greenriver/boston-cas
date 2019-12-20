class CreateNameQualityCodes < ActiveRecord::Migration[4.2]
  def change
    create_table :name_quality_codes do |t|
      t.integer :numeric
      t.string :text

      t.timestamps null: false
    end
  end
end
