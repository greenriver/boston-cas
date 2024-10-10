###
# Copyright 2016 - 2024 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

module Notifications::Eleven
  class ConfirmMatchSuccessDndStaff < ::Notifications::Base
    def self.create_for_match! match
      match.dnd_staff_contacts.each do |contact|
        create! match: match, recipient: contact
      end
    end

    def decision
      match.eleven_confirm_match_success_dnd_staff_decision
    end

    def event_label
      "#{Translation.translate('CoC Eleven')} Staff notified of successful match and asked to give final confirmation."
    end
  end
end
