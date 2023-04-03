###
# Copyright 2016 - 2023 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

module Notifications
  class MatchRecommendationHousingSubsidyAdmin < Base

    def self.create_for_match! match
      match.housing_subsidy_admin_contacts.each do |contact|
        create! match: match, recipient: contact
      end
    end

    def event_label
      "#{_('Housing Subsidy Administrator')} notified of potential match (no client details sent)"
    end

    def show_client_info?
      false
    end

    def allows_registration?
      true
    end

    def registration_role
      :housing_subsidy_admin
    end

  end
end
