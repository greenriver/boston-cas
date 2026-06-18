###
# Copyright Green River Data Group, Inc.
#
# License detail: https://github.com/greenriver/boston-cas/blob/stable/LICENSE.md
###

# frozen_string_literal: true

module Notifications::Five
  class Screening < Base
    def self.contact_types_for_notification
      [:shelter_agency_contacts]
    end

    def decision
      match.five_screening_decision
    end

    def event_label
      "#{match_route.contact_label_for(:shelter_agency_contacts)} notified of screening"
    end
  end
end
