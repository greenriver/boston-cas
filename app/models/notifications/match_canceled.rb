###
# Copyright 2016 - 2025 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

# frozen_string_literal: true

module Notifications
  class MatchCanceled < Base
    def self.contact_types_for_notification
      # Complex logic: sends to all contacts except DND staff, and conditionally excludes HSA/SSP/HSP
      []
    end

    def self.create_for_match!(match, decision_id: nil)
      contacts = match.contacts - match.dnd_staff_contacts
      # don't send to the HSA, SSP, or HSP contacts unless they have been involved
      contacts -= (match.housing_subsidy_admin_contacts + match.ssp_contacts + match.hsp_contacts) unless match.hsa_involved?

      contacts.each do |contact|
        create!(match: match, recipient: contact, decision_id_for_delivery: decision_id)
      end
    end

    def event_label
      'Contact notified, match canceled'
    end
  end
end
