class AddCancelReasonsToDecisions < ActiveRecord::Migration
  def change
    change_table :match_decisions do |t|
      t.references :administrative_cancel_reason, index: true
    end
  end
end
