###
# Copyright 2016 - 2025 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

# frozen_string_literal: true

module Notifications::Thirteen
  class ThirteenAcceptReferralHsa < ::Notifications::Base
    def self.contact_types_for_notification
      [:housing_subsidy_admin_contacts]
    end

    def decision
      match.thirteen_accept_referral_decision
    end

    def event_label
      "#{Translation.translate('HSA Thirteen')} notified of match update - pending #{Translation.translate('HSA Thirteen')} accepting referral."
    end
  end
end
