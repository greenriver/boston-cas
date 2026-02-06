###
# Copyright 2016 - 2025 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

# frozen_string_literal: true

module Notifications::Five
  class MatchRecommendation < Base
    def self.contact_types_for_notification
      [:housing_subsidy_admin_contacts]
    end

    def self.create_for_match! match
      contact_types_for_notification.each do |contact_type|
        match.send(contact_type).each do |contact|
          create! match: match, recipient: contact
        end
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
