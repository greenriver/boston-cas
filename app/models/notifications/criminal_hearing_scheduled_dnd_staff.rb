###
# Copyright 2016 - 2019 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/master/LICENSE.md
###

module Notifications
  class CriminalHearingScheduledDndStaff < Base
    
    def self.create_for_match! match
      match.dnd_staff_contacts.each do |contact|
        create! match: match, recipient: contact
      end
    end

    def event_label
      label = _('DND')
      label += ' '
      label += _('sent notice of criminal background hearing date.')
    end

  end
end
