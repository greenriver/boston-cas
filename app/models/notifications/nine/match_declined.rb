###
# Copyright 2016 - 2023 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

module Notifications::Nine
  class MatchDeclined < Notifications::MatchDeclined
    def self.create_for_match! match
      # DND will receive confirmation step, so they don't need the notification
      contacts = match.contacts - match.dnd_staff_contacts

      contacts.each do |contact|
        create! match: match, recipient: contact
      end
    end
  end
end
