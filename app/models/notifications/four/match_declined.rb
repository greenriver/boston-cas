###
# Copyright 2016 - 2025 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

# frozen_string_literal: true

module Notifications::Four
  class MatchDeclined < Notifications::MatchDeclined
    def self.contact_types_for_notification
      # DND will receive confirmation step, so they don't need the notification
      []
    end

    def self.notification_recipients_for(match)
      match.contacts - match.dnd_staff_contacts
    end
  end
end
