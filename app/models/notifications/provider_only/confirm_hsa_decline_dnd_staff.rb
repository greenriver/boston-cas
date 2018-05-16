module Notifications::ProviderOnly
  class ConfirmHsaDeclineDndStaff < ::Notifications::Base
    
    def self.create_for_match! match
      match.dnd_staff_contacts.each do |contact|
        create! match: match, recipient: contact
      end
    end
    
    def decision
      match.confirm_hsa_accepts_client_decline_dnd_staff_decision
    end

    def event_label
      "#{_('DND')} notified of #{_('housing subsidy administrator')} decline.  Confirmation pending."
    end

  end
end
