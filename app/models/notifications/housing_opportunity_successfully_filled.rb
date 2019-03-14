module Notifications
  class HousingOpportunitySuccessfullyFilled < Base

    def self.create_for_match! match
      contacts = match.contacts

      contacts.each do |contact|
        create! match: match, recipient: contact
      end
    end

    def event_label
      'Vacancy filled by other client'
    end
  end
end