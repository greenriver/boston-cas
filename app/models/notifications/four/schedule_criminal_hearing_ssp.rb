###
# Copyright Green River Data Group, Inc.
#
# License detail: https://github.com/greenriver/boston-cas/blob/stable/LICENSE.md
###

# frozen_string_literal: true

module Notifications::Four
  class ScheduleCriminalHearingSsp < ::Notifications::ScheduleCriminalHearingSsp
    def decision
      match.four_schedule_criminal_hearing_housing_subsidy_admin_decision
    end
  end
end
