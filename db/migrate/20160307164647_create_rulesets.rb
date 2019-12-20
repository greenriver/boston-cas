class CreateRulesets < ActiveRecord::Migration[4.2]
  def change
    create_table :rulesets do |t|
      t.string :name, null: false

      t.references :user, index: true, null: false
      t.timestamps null: false

      # be paranoid
      t.datetime :deleted_at, index: true, null: true
    end
  end
end
