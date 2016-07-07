class RenameRulesIdToRuleIdInRequirements < ActiveRecord::Migration
  def change
    rename_column :requirements, :rules_id, :rule_id
  end
end
