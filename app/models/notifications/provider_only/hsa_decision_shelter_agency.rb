module Notifications::ProviderOnly
  class HsaDecisionShelterAgency < ::Notifications::Base
    # Notification sent to DND staff of an approval decision made by the housing subsidy administrator
    
    # rejections are handled in a separate notification with a link to the opportunity to override.
    
    def self.create_for_match! match
      match.shelter_agency_contacts.each do |contact|
        create! match: match, recipient: contact
      end
    end

    def event_label
      "#{_('Shelter Agency')} sent notice of #{_('Housing Subsidy Administrator')}'s decision."
    end

  end
end
