###
# Copyright Green River Data Group, Inc.
#
# License detail: https://github.com/greenriver/boston-cas/blob/stable/LICENSE.md
###

# frozen_string_literal: true

module Notifications::Twelve
  class TwelveHsaConfirmMatchSuccess < ::Notifications::Base
    def self.contact_types_for_notification
      [:housing_subsidy_admin_contacts]
    end

    def decision
      match.twelve_hsa_confirm_match_success_decision
    end

    def event_label
      "#{Translation.translate('HSA Twelve')} notified of match."
    end
  end
end
