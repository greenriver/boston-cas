class CreateMitigationReasons < ActiveRecord::Migration[6.0]
  def change
    create_table :mitigation_reasons do |t|
      t.string :name
      t.boolean :active, default: :true

      t.timestamps
    end
  end
end
