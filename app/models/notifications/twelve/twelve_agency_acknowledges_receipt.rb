###
# Copyright 2016 - 2025 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

# frozen_string_literal: true

module Notifications::Twelve
  class TwelveAgencyAcknowledgesReceipt < ::Notifications::Base
    def self.contact_types_for_notification
      [:shelter_agency_contacts]
    end

    def self.create_for_match! match
      contact_types_for_notification.each do |contact_type|
        match.send(contact_type).each do |contact|
          create! match: match, recipient: contact
        end
      end
    end

    def decision
      match.twelve_agency_acknowledges_receipt_decision
    end

    def event_label
      "#{Translation.translate('Shelter Agency Twelve')} notified of match detail"
    end
  end
end
