###
# Copyright 2016 - 2023 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

module Notifications::Four
  class ScheduleCriminalHearingHousingSubsidyAdmin < ::Notifications::ScheduleCriminalHearingHousingSubsidyAdmin

    def decision
      match.four_schedule_criminal_hearing_housing_subsidy_admin_decision
    end

  end
end
