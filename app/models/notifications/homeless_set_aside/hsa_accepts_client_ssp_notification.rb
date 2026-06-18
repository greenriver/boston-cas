###
# Copyright Green River Data Group, Inc.
#
# License detail: https://github.com/greenriver/boston-cas/blob/stable/LICENSE.md
###

# frozen_string_literal: true

module Notifications::HomelessSetAside
  class HsaAcceptsClientSspNotification < ::Notifications::Base
    def self.contact_types_for_notification
      [:ssp_contacts]
    end

    def event_label
      "#{Translation.translate('SSP')} notified of #{Translation.translate('Housing Subsidy Administrator')} acceptance"
    end

    def show_client_info?
      true
    end

    def allows_registration?
      false
    end
  end
end
