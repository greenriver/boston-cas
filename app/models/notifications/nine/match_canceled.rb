###
# Copyright 2016 - 2022 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

module Notifications::Nine
  class MatchCanceled < Notifications::MatchCanceled
    # Send to all contacts
    def self.create_for_match! match
      contacts = match.contacts

      contacts.each do |contact|
        create! match: match, recipient: contact
      end
    end
  end
end