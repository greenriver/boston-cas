###
# Copyright 2016 - 2022 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

module Notifications::Nine
  class DndStaffAssignsCaseContact < Notifications::Base
    def self.create_for_match! match
      match.dnd_staff_contacts.each do |contact|
        create! match: match, recipient: contact
      end
    end

    def decision
      match.dnd_staff_assigns_case_contact_decision
    end

    def event_label
      "#{_('DND')} notified match needs #{_('Stabilization Service Provider Nine')}"
    end
  end
end
