module Notifications
  class CriminalHearingScheduledHsp < Base
    
    def self.create_for_match! match
      match.hsp_contacts.each do |contact|
        create! match: match, recipient: contact
      end
    end

    def event_label
      label = _('Housing Search Provider')
      label += ' '
      label += _('sent notice of criminal background hearing date.')
    end

  end
end
