###
# Copyright 2016 - 2023 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

module Notifications::Nine
  class NineConfirmAssignManagerDecline < ::Notifications::Base
    def self.create_for_match! match
      match.dnd_staff_contacts.each do |contact|
        create! match: match, recipient: contact
      end
    end

    def decision
      match.nine_confirm_assign_manager_decline_decision
    end

    def event_label
      "#{_('DND')} notified of #{_('Stabilization Service Provider Nine')} decline. Confirmation pending."
    end
  end
end
