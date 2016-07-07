class ChangeRuleSchemaForMvp < ActiveRecord::Migration
  def change
    drop_rule_sources
    drop_rulesets
    drop_rules_rulesets
    change_rules
    create_requirements
  end

  private

  def change_rules
    remove_column :rules, :subject, :string
    remove_column :rules, :condition, :string
    remove_column :rules, :object, :string
    change_table :rules do |t|
      t.string :code_ident, index: true
    end
  end

  def create_requirements
    create_table :requirements do |t|
      t.belongs_to :rules, index: true
      t.references :required_by, polymorphic: true, index: true
      t.boolean :positive
      t.datetime :deleted_at, index: true, null: true
      t.timestamps
    end
  end

  def drop_rule_sources
    drop_table :rule_sources do |t|
      t.string :name
      t.string :subject
      t.boolean :active
      t.datetime :deleted_at, index: true, null: true
    end
  end

  def drop_rules_rulesets
    drop_table :rules_rulesets do |t|
      t.integer :rules_id
      t.integer :rulesets_id
      t.integer :weight
    end
  end

  def drop_rulesets
    drop_table :rulesets do |t|
      t.string :name, null: false
      t.belongs_to :users, null: false
      t.timestamps
    end
  end
end
