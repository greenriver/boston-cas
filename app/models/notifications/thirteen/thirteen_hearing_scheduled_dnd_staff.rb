###
# Copyright 2016 - 2024 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

module Notifications::Thirteen
  class ThirteenHearingScheduledDndStaff < ::Notifications::Base
    def self.create_for_match! match
      match.dnd_staff_contacts.each do |contact|
        create! match: match, recipient: contact
      end
    end

    def decision
      match.thirteen_hearing_scheduled_decision
    end

    def event_label
      "#{Translation.translate('CoC Thirteen')} notified of pending CORI review."
    end

    def to_partial_path
      "notifications/thirteen/#{notification_type}"
    end
  end
end
