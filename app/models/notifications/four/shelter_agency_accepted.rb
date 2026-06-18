###
# Copyright Green River Data Group, Inc.
#
# License detail: https://github.com/greenriver/boston-cas/blob/stable/LICENSE.md
###

# frozen_string_literal: true

module Notifications::Four
  class ShelterAgencyAccepted < ::Notifications::Base
    def self.contact_types_for_notification
      [:dnd_staff_contacts]
    end

    def decision
      match.four_match_recommendation_hsa_decision
    end

    def event_label
      "#{Translation.translate('DND')}  notified of #{Translation.translate('Shelter Agency')} match acceptance"
    end
  end
end
