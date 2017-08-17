module Notifications
  class HousingSubsidyAdminAcceptedMatchDndStaff < Base
    # Notification sent to dnd staff of an approval decision made by the housing subsidy administrator
    
    # rejections are handled in a separate notification with a link to the opportunity to override.
    
    def self.create_for_match! match
      match.dnd_staff_contacts.each do |contact|
        create! match: match, recipient: contact
      end
    end

    def event_label
      "Sent notice of #{_('Housing Subsidy Administrator')}'s decision to #{_('DND')}"
    end

    def should_expire?
      false
    end
    
  end
end
