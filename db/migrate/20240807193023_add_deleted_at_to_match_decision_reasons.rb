class AddDeletedAtToMatchDecisionReasons < ActiveRecord::Migration[7.0]
  def change
    add_column :match_decision_reasons, :deleted_at, :datetime
  end
end
