###
# Copyright 2016 - 2025 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

# frozen_string_literal: true

module Notifications::ProviderOnly
  class ConfirmHsaDeclineDndStaff < ::Notifications::Base
    def self.contact_types_for_notification
      [:dnd_staff_contacts]
    end

    def decision
      match.confirm_hsa_accepts_client_decline_dnd_staff_decision
    end

    def event_label
      "#{Translation.translate('DND')} notified of #{Translation.translate('housing subsidy administrator')} decline.  Confirmation pending."
    end
  end
end
