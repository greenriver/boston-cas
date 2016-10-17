module Notifications
  class MoveInDateSet < Base
    
    def self.create_for_match! match
      match.shelter_agency_contacts.each do |contact|
        create! match: match, recipient: contact
      end
      match.housing_subsidy_admin_contacts.each do |contact|
        create! match: match, recipient: contact
      end
    end

    def event_label
      'Shelter Agency and Housing Subsidy Administrator contacts notified, lease start date set.'
    end

    def should_expire?
      true
    end

  end
end
