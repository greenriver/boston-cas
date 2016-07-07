class CreateDateOfBirthQualityCodes < ActiveRecord::Migration
  def change
    create_table :date_of_birth_quality_codes do |t|
      t.integer :numeric
      t.string :text

      t.timestamps null: false
    end
  end
end
