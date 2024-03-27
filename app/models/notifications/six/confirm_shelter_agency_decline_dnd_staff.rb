###
# Copyright 2016 - 2024 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

module Notifications::Six
  class ConfirmShelterAgencyDeclineDndStaff < ::Notifications::ConfirmShelterAgencyDeclineDndStaff
    def notification_type
      # prefix used for finding relevant information in other objects
      # e.g. mailer, match decisions
      "six_#{self.class.to_s.demodulize.underscore}"
    end

    def decision
      match.six_confirm_shelter_agency_decline_dnd_staff_decision
    end
  end
end
