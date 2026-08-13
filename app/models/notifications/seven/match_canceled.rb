###
# Copyright Green River Data Group, Inc.
#
# License detail: https://github.com/greenriver/boston-cas/blob/stable/LICENSE.md
###

# frozen_string_literal: true

module Notifications::Seven
  class MatchCanceled < Notifications::MatchCanceled
    # Send to all contacts
    def self.contact_types_for_notification
      [:contacts]
    end

    def self.notification_recipients_for(match)
      match.contacts
    end
  end
end
