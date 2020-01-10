###
# Copyright 2016 - 2020 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/master/LICENSE.md
###

module Notifications::Four
  class ScheduleCriminalHearingHsp < ::Notifications::ScheduleCriminalHearingHsp

    def decision
      match.four_schedule_criminal_hearing_housing_subsidy_admin_decision
    end

  end
end
