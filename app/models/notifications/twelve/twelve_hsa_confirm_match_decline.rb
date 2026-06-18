###
# Copyright Green River Data Group, Inc.
#
# License detail: https://github.com/greenriver/boston-cas/blob/stable/LICENSE.md
###

# frozen_string_literal: true

module Notifications::Twelve
  class TwelveHsaConfirmMatchDecline < ::Notifications::Base
    def self.contact_types_for_notification
      [:dnd_staff_contacts]
    end

    def decision
      match.confirm_housing_subsidy_admin_decline_dnd_staff_decision
    end

    def event_label
      "#{Translation.translate('CoC Twelve')} notified of #{Translation.translate('HSA Twelve')} decline.  Confirmation pending."
    end
  end
end
