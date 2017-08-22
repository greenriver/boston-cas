module Notifications
  class HousingSubsidyAdminDeclinedMatchSsp < Base
    # Notification sent to dnd staff of an approval decision made by the housing subsidy administrator
    
    # rejections are handled in a separate notification with a link to the opportunity to override.
    
    def self.create_for_match! match
      match.ssp_contacts.each do |contact|
        create! match: match, recipient: contact
      end
    end

    def event_label
      "Sent notice of #{_('Housing Subsidy Administrator')}'s decision to #{('Stabilization Services Provider')}"
    end

    def should_expire?
      false
    end
    
  end
end
