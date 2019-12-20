class AddOtherCancelReason < ActiveRecord::Migration[4.2]
  def change
    add_column :match_decisions, :administrative_cancel_reason_other_explanation, :string
  end
end
