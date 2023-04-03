###
# Copyright 2016 - 2023 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

module Notifications::Four
  class ShelterAgencyDeclineAccepted < ::Notifications::ShelterAgencyDeclineAccepted

    def decision
      match.four_confirm_shelter_agency_decline_dnd_staff_decision
    end

  end
end
