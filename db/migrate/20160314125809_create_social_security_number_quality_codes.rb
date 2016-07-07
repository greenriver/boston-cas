class CreateSocialSecurityNumberQualityCodes < ActiveRecord::Migration
  def change
    create_table :social_security_number_quality_codes do |t|
      t.integer :numeric
      t.string :text

      t.timestamps null: false
    end
  end
end
