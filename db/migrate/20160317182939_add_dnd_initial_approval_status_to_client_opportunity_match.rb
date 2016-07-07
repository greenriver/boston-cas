class AddDndInitialApprovalStatusToClientOpportunityMatch < ActiveRecord::Migration
  def change
    add_column :client_opportunity_matches, :dnd_recommendation_status, :string
  end
end
