module Notifications
  class CriminalHearingScheduledHousingSubsidyAdmin < Base
    
    def self.create_for_match! match
      match.housing_subsidy_admin_contacts.each do |contact|
        create! match: match, recipient: contact
      end
    end

    def event_label
      "#{_('Housing Subsidy Administrator')} sent notice of criminal background hearing date."
    end

    def should_expire?
      true
    end
    
  end
end
