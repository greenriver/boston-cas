class CreateRules < ActiveRecord::Migration
  def change
    create_table :rules do |t|
      t.string :name, null: false
      t.string :subject, null: false # this is a representation of a column somewhere else
      t.string :condition, null: false
      t.string :object, null: false

      t.timestamps null: false

      # be paranoid
      t.datetime :deleted_at, index: true, null: true
    end

    create_table :rules_rulesets, id: false do |t|
      t.belongs_to :rules, index: true
      t.belongs_to :rulesets, index: true
      t.integer :weight, null: true
    end

    create_table :rule_sources do |t|
      t.string :name, null: false
      t.string :subject, null: false
      #t.string :condition, null: false
      #t.string :options, null: true
      t.boolean :active, null: false, default: true
      # be paranoid
      t.datetime :deleted_at, index: true, null: true
    end
  end
end
