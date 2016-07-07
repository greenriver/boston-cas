class AddMatchRecommendationHousingSubsidyAdminDecisionAttributes < ActiveRecord::Migration
  def change
    add_column :client_opportunity_matches, :match_recommendation_housing_subsidy_admin_status, :string
    add_column :client_opportunity_matches, :match_recommendation_housing_subsidy_admin_contact_id, :integer
    add_column :client_opportunity_matches, :match_recommendation_housing_subsidy_admin_timestamp, :datetime
  end
end
