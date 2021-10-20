class AddLimitedToMatchDecisionReasons < ActiveRecord::Migration[6.0]
  def change
    add_column :match_decision_reasons, :limited, :boolean, default: false
  end
end
