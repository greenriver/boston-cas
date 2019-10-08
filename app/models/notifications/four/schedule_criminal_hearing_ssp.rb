###
# Copyright 2016 - 2019 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/master/LICENSE.md
###

module Notifications::Four
  class ScheduleCriminalHearingSsp < ::Notifications::ScheduleCriminalHearingSsp

    def decision
      match.four_schedule_criminal_hearing_housing_subsidy_admin_decision
    end

  end
end
