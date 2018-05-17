module Notifications::ProviderOnly
  class HsaDecisionHsp < ::Notifications::Base
    # Notification sent to a client of a decision made by the housing subsidy administrator
    
    def self.create_for_match! match
      match.hsp_contacts.each do |contact|
        create! match: match, recipient: contact
      end
    end

    def event_label
      "#{_('Housing Search Provider')} sent notice of #{_('Housing Subsidy Administrator')}'s decision."
    end

  end
end
