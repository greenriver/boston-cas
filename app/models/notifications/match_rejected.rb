###
# Copyright 2016 - 2025 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

# frozen_string_literal: true

module Notifications
  class MatchRejected < Base
    def self.contact_types_for_notification
      [:contacts]
    end

    def event_label
      'Contacts notified, match rejected'
    end
  end
end
