###
# Copyright 2016 - 2023 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

module Notifications
  class NoLongerWorkingWithClient < Base
    attr_accessor :agency_contact
    def self.create_for_match! match
      match.dnd_staff_contacts.each do |contact|
        create! match: match, recipient: contact
      end
    end

    def event_label
      "#{_('DND')} notified, contact no longer working with client"
    end

  end
end
