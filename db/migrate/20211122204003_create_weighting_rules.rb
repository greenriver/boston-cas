class CreateWeightingRules < ActiveRecord::Migration[6.0]
  def change
    create_table :weighting_rules do |t|
      t.references :route
      t.references :requirement
      t.integer :applied_to, default: 0
      t.timestamps
      t.datetime :deleted_at
    end
  end
end
