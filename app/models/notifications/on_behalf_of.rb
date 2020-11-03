###
# Copyright 2016 - 2020 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

module Notifications
  class OnBehalfOf < Base

    def self.create_for_match! match, contact_type
      match.send(contact_type).each do |contact|
        create! match: match, recipient: contact
      end
    end

    def event_label
      "Contact notified, action taken by #{_('DND')}"
    end

  end
end
