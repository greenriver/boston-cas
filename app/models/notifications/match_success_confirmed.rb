###
# Copyright 2016 - 2024 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

module Notifications
  class MatchSuccessConfirmed < Base

    def self.create_for_match! match
      match.contacts.each do |contact|
        create! match: match, recipient: contact
      end
    end

    def event_label
      "Contact notified of match success confirmation."
    end

  end
end
