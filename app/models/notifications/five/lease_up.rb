###
# Copyright Green River Data Group, Inc.
#
# License detail: https://github.com/greenriver/boston-cas/blob/stable/LICENSE.md
###

# frozen_string_literal: true

module Notifications::Five
  class LeaseUp < Base
    def self.contact_types_for_notification
      [:shelter_agency_contacts]
    end

    def decision
      match.five_lease_up_decision
    end

    def event_label
      "Awaiting #{match_route.contact_label_for(:shelter_agency_contacts)} Lease Up"
    end
  end
end
