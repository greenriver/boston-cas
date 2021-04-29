class AddDisableOpportunityToMatchDecisions < ActiveRecord::Migration[6.0]
  def change
    add_column :match_decisions, :disable_opportunity, :boolean, default: false
  end
end
