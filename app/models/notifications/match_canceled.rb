###
# Copyright 2016 - 2020 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/master/LICENSE.md
###

module Notifications
  class MatchCanceled < Base

    def self.create_for_match! match
      contacts = match.contacts - match.dnd_staff_contacts
      # don't send to the HSA, SSP, or HSP contacts unless they have been involved
      contacts -= (match.housing_subsidy_admin_contacts + match.ssp_contacts + match.hsp_contacts) unless match.hsa_involved?

      contacts.each do |contact|
        create! match: match, recipient: contact
      end
    end

    def event_label
      'Contact notified, match canceled'
    end
  end
end
