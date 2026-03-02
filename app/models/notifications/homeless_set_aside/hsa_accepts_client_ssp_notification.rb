###
# Copyright 2016 - 2025 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

# frozen_string_literal: true

module Notifications::HomelessSetAside
  class HsaAcceptsClientSspNotification < ::Notifications::Base
    def self.contact_types_for_notification
      [:ssp_contacts]
    end

    def self.create_for_match! match
      contact_types_for_notification.each do |contact_type|
        match.send(contact_type).each do |contact|
          create! match: match, recipient: contact
        end
      end
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
