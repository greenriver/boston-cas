###
# Copyright 2016 - 2022 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

module Notifications::Four
  class ConfirmHsaInitialDeclineDndStaff < ConfirmHousingSubsidyAdminDeclineDndStaff

    def decision
      match.four_confirm_hsa_initial_decline_dnd_staff_decision
    end

  end
end
