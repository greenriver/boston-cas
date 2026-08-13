###
# Copyright Green River Data Group, Inc.
#
# License detail: https://github.com/greenriver/boston-cas/blob/stable/LICENSE.md
###

# frozen_string_literal: true

module Notifications
  class MatchRecommendationClient < Base
    def self.contact_types_for_notification
      [:client_contacts]
    end

    def event_label
      'Client notified of potential match'
    end
  end
end
