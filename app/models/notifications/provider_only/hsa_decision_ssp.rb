module Notifications::ProviderOnly
  class HsaDecisionSsp < ::Notifications::Base
    # Notification sent to a client of a decision made by the housing subsidy administrator
    
    def self.create_for_match! match
      match.ssp_contacts.each do |contact|
        create! match: match, recipient: contact
      end
    end

    def event_label
      "#{_('Stabilization Services Provider')} sent notice of #{_('Housing Subsidy Administrator')}'s decision."
    end

  end
end
