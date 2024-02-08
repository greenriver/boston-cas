###
# Copyright 2016 - 2024 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

module Notifications::Nine
  class NineAssignCaseContact < Notifications::Base
    def self.create_for_match! match
      match.dnd_staff_contacts.each do |contact|
        create! match: match, recipient: contact
      end
    end

    def decision
      match.nine_assign_case_contact_decision
    end

    def event_label
      "#{Translation.translate('DND')} notified match needs #{Translation.translate('Stabilization Service Provider Nine')} Contact"
    end
  end
end
