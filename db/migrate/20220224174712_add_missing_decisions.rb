class AddMissingDecisions < ActiveRecord::Migration[6.0]
  def up
    ClientOpportunityMatch.on_route(MatchRoutes::Default.first).
      preload(:confirm_shelter_decline_of_housed_decision, :confirm_shelter_decline_of_hearing_decision, :confirm_shelter_decline_of_hsa_approval_decision).
      find_each do |match|
        match.create_confirm_shelter_decline_of_housed_decision unless match.confirm_shelter_decline_of_housed_decision.present?
        match.create_confirm_shelter_decline_of_hearing_decision unless match.confirm_shelter_decline_of_hearing_decision.present?
        match.create_confirm_shelter_decline_of_hsa_approval_decision unless match.confirm_shelter_decline_of_hsa_approval_decision.present?
      end
  end
end
