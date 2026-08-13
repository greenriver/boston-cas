###
# Copyright Green River Data Group, Inc.
#
# License detail: https://github.com/greenriver/boston-cas/blob/stable/LICENSE.md
###

# frozen_string_literal: true

module Notifications::Five
  class MatchRecommendation < Base
    def self.contact_types_for_notification
      [:housing_subsidy_admin_contacts]
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
