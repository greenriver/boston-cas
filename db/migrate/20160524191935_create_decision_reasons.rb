class CreateDecisionReasons < ActiveRecord::Migration
  def change
    create_table :match_decision_reasons do |t|
      t.string :name, null: false
      t.string :type, null: false, index: true
      t.timestamps
    end
  end
end
