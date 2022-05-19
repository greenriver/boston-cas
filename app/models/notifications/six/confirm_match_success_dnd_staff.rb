###
# Copyright 2016 - 2022 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

module Notifications::Six
  class ConfirmMatchSuccessDndStaff < ::Notifications::Base
    def self.create_for_match! match
      match.dnd_staff_contacts.each do |contact|
        create! match: match, recipient: contact
      end
    end

    def decision
      match.six_confirm_match_success_dnd_staff_decision
    end

    def event_label
      "#{_('DND')} Staff notified of successful match and asked to give final confirmation."
    end
  end
end
