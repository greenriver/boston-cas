###
# Copyright Green River Data Group, Inc.
#
# License detail: https://github.com/greenriver/boston-cas/blob/stable/LICENSE.md
###

# frozen_string_literal: true

module Notifications::Five
  class Mitigation < Base
    def self.contact_types_for_notification
      [:shelter_agency_contacts]
    end

    def decision
      match.five_mitigation_decision
    end

    def event_label
      "#{match_route.contact_label_for(:shelter_agency_contacts)} performing mitigation"
    end
  end
end
