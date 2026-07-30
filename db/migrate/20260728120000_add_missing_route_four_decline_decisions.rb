# frozen_string_literal: true

class AddMissingRouteFourDeclineDecisions < ActiveRecord::Migration[7.1]
  def up
    # Add new decline decisions for route four
    ClientOpportunityMatch.on_route(MatchRoutes::Four.first).
      preload(:four_confirm_schedule_criminal_hearing_decline_dnd_staff_decision, :four_confirm_record_client_housed_date_decline_dnd_staff_decision).
      find_each do |match|
        match.create_four_confirm_schedule_criminal_hearing_decline_dnd_staff_decision unless match.four_confirm_schedule_criminal_hearing_decline_dnd_staff_decision.present?
        match.create_four_confirm_record_client_housed_date_decline_dnd_staff_decision unless match.four_confirm_record_client_housed_date_decline_dnd_staff_decision.present?
      end
  end
end
