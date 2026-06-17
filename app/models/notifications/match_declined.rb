###
# Copyright Green River Data Group, Inc.
#
# License detail: https://github.com/greenriver/boston-cas/blob/stable/LICENSE.md
###

# frozen_string_literal: true

module Notifications
  class MatchDeclined < Base
    def self.contact_types_for_notification
      [:contacts]
    end

    def event_label
      'Contacts notified, match declined'
    end
  end
end
