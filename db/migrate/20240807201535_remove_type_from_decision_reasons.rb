class RemoveTypeFromDecisionReasons < ActiveRecord::Migration[7.0]
  def change
    remove_column :match_decision_reasons, :type, :string
  end
end
