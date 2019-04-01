module Notifications
  class MatchSuccessConfirmedDevelopmentOfficer < Base
    def self.create_for_match!(match)
      match.do_contacts.each do |contact|
        create! match: match, recipient: contact
      end
    end

    def event_label
      "#{_('Development Officer')} notified of match success confirmation."
    end
  end
end
