###
# Copyright Green River Data Group, Inc.
#
# License detail: https://github.com/greenriver/boston-cas/blob/stable/LICENSE.md
###

# frozen_string_literal: true

module Notifications::Four
  class ShelterAgencyDeclineAccepted < ::Notifications::ShelterAgencyDeclineAccepted
    def decision
      match.four_confirm_shelter_agency_decline_dnd_staff_decision
    end
  end
end
