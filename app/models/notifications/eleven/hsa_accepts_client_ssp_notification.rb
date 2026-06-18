###
# Copyright Green River Data Group, Inc.
#
# License detail: https://github.com/greenriver/boston-cas/blob/stable/LICENSE.md
###

# frozen_string_literal: true

module Notifications::Eleven
  class HsaAcceptsClientSspNotification < ::Notifications::Base
    def self.contact_types_for_notification
      [:ssp_contacts]
    end

    def notification_type
      # prefix used for finding relevant information in other objects
      # e.g. mailer, match decisions
      "eleven_#{self.class.to_s.demodulize.underscore}"
    end

    def event_label
      "#{Translation.translate('SSP Eleven')} notified of #{Translation.translate('Housing Subsidy Administrator Eleven')} acceptance"
    end

    def show_client_info?
      true
    end

    def allows_registration?
      false
    end
  end
end
