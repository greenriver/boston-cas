###
# Copyright 2016 - 2025 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

# frozen_string_literal: true

module Notifications::Four
  class MatchRecommendationHousingSubsidyAdmin < ::Notifications::Base
    def self.contact_types_for_notification
      [:housing_subsidy_admin_contacts]
    end

    def event_label
      "#{Translation.translate('Housing Subsidy Administrator')} notified of match recommendation"
    end

    def decision
      match.four_match_recommendation_shelter_agency_decision
    end

    def show_client_info?
      true
    end

    def allows_registration?
      true
    end

    def registration_role
      :housing_subsidy_admin
    end
  end
end
