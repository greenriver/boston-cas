###
# Copyright 2016 - 2024 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

module Notifications::Twelve
  class TwelveAgencyAcknowledgesReceipt < ::Notifications::Base
    def self.create_for_match! match
      match.shelter_agency_contacts.each do |contact|
        create! match: match, recipient: contact
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
