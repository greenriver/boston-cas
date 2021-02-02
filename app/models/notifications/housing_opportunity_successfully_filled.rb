###
# Copyright 2016 - 2021 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

module Notifications
  class HousingOpportunitySuccessfullyFilled < Base

    def self.create_for_match! match
      contacts = match.contacts

      contacts.each do |contact|
        create! match: match, recipient: contact
      end
    end

    def event_label
      'Contact notified that vacancy was filled by other client'
    end
  end
end
