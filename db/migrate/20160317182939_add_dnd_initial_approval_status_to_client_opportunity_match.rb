class AddDndInitialApprovalStatusToClientOpportunityMatch < ActiveRecord::Migration[4.2]
  def change
    add_column :client_opportunity_matches, :dnd_recommendation_status, :string
  end
end
