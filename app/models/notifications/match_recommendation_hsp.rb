###
# Copyright Green River Data Group, Inc.
#
# License detail: https://github.com/greenriver/boston-cas/blob/stable/LICENSE.md
###

# frozen_string_literal: true

module Notifications
  class MatchRecommendationHsp < Base
    def self.contact_types_for_notification
      [:hsp_contacts]
    end

    def event_label
      "#{Translation.translate('Housing Search Provider')} notified of potential match (no client details sent)"
    end

    def show_client_info?
      false
    end
  end
end
