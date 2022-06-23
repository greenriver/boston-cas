###
# Copyright 2016 - 2022 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

module Notifications
  class ProgressUpdateSubmitted < Base
    def self.create_for_match! match
      match.dnd_staff_contacts.each do |contact|
        create! match: match, recipient: contact
      end
      return unless Config.get(:notify_all_on_progress_update)

      match.housing_subsidy_admin_contacts.each do |contact|
        create! match: match, recipient: contact
      end
      # client_contacts skipped
      match.shelter_agency_contacts.each do |contact|
        create! match: match, recipient: contact
      end
      match.ssp_contacts.each do |contact|
        create! match: match, recipient: contact
      end
      match.hsp_contacts.each do |contact|
        create! match: match, recipient: contact
      end
      # do_contacts skipped
    end

    def event_label
      if Config.get(:notify_all_on_progress_update)
        'Progress update submitted, all contacts notified'
      else
        "Progress update submitted, #{_('DND')} notified"
      end
    end
  end
end
