###
# Copyright 2016 - 2025 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

# frozen_string_literal: true

module Notifications::Thirteen
  class ThirteenHearingOutcomeDecline < ::Notifications::Base
    def self.contact_types_for_notification
      [:dnd_staff_contacts]
    end

    def decision
      match.thirteen_hearing_outcome_decline_decision
    end

    def event_label
      "#{Translation.translate('CoC Thirteen')} notified of #{Translation.translate('HSA Thirteen')} decline.  Confirmation pending."
    end
  end
end
