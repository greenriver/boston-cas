module Notifications
  class HousingSubsidyAdminDeclinedMatchHsp < Base
    def self.create_for_match!(match)
      match.hsp_contacts.each do |contact|
        create! match: match, recipient: contact
      end
    end

    def event_label
      "Sent notice of #{_('Housing Subsidy Administrator')}'s decision to Housing Search Provider"
    end
  end
end
