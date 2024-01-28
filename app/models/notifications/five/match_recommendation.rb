###
# Copyright 2016 - 2024 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

module Notifications::Five
  class MatchRecommendation < Base
    def self.create_for_match! match
      match.housing_subsidy_admin_contacts.each do |contact|
        create! match: match, recipient: contact
      end
    end

    def decision
      match.five_match_recommendation_decision
    end

    def event_label
      "#{match_route.contact_label_for(:housing_subsidy_admin_contacts)} notified of new match"
    end

    def contacts_editable?
      true
    end
  end
end
