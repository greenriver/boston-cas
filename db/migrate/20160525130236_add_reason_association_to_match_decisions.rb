class AddReasonAssociationToMatchDecisions < ActiveRecord::Migration[4.2]
  def change
    change_table :match_decisions do |t|
      t.references :match_decision_reason, index: true
      t.text :other_reason_explanation
    end
  end
end
