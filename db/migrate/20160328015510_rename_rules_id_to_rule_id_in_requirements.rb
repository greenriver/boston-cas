class RenameRulesIdToRuleIdInRequirements < ActiveRecord::Migration[4.2]
  def change
    rename_column :requirements, :rules_id, :rule_id
  end
end
