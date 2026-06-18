###
# Copyright Green River Data Group, Inc.
#
# License detail: https://github.com/greenriver/boston-cas/blob/stable/LICENSE.md
###

# frozen_string_literal: true

module Notifications::Thirteen
  class ThirteenAcceptReferralSsp < ::Notifications::Base
    def self.contact_types_for_notification
      [:ssp_contacts]
    end

    def decision
      match.thirteen_accept_referral_decision
    end

    def event_label
      "#{Translation.translate('Stabilization Service Providers Thirteen')} notified of match update - pending #{Translation.translate('HSA Thirteen')} accepting referral."
    end
  end
end
