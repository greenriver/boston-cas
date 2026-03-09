###
# Copyright 2016 - 2025 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

# frozen_string_literal: true

module Notifications::Six
  class ConfirmHsaDeclineDndStaff < ::Notifications::Base
    def self.contact_types_for_notification
      [:dnd_staff_contacts]
    end

    def notification_type
      # prefix used for finding relevant information in other objects
      # e.g. mailer, match decisions
      "six_#{self.class.to_s.demodulize.underscore}"
    end

    def decision
      match.six_confirm_housing_subsidy_admin_decline_dnd_staff_decision
    end

    def event_label
      "#{Translation.translate('CoC Six')} notified of #{Translation.translate('Housing Subsidy Administrator Six')} decline. Confirmation pending."
    end
  end
end
