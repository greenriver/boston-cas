###
# Copyright Green River Data Group, Inc.
#
# License detail: https://github.com/greenriver/boston-cas/blob/stable/LICENSE.md
###

# frozen_string_literal: true

module Notifications::Five
  class ClientAgrees < Base
    def self.contact_types_for_notification
      [:shelter_agency_contacts]
    end

    def decision
      match.five_client_agrees_decision
    end

    def event_label
      "#{match_route.contact_label_for(:shelter_agency_contacts)} requested to confirm client accepts match"
    end
  end
end
