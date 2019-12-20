class AddDedicatedColumnsForNotWorkingWithClientReasonAssociation < ActiveRecord::Migration[4.2]
  def change
    change_table :match_decisions do |t|
      t.remove :match_decision_reason_id
      t.remove :other_reason_explanation

      t.references :decline_reason, index: true
      t.text :decline_reason_other_explanation

      t.references :not_working_with_client_reason, index: true
      t.text :not_working_with_client_reason_other_explanation
    end
  end
end
