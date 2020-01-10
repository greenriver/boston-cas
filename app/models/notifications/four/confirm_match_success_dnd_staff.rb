###
# Copyright 2016 - 2020 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/master/LICENSE.md
###

module Notifications::Four
  class ConfirmMatchSuccessDndStaff < ::Notifications::ConfirmMatchSuccessDndStaff

    def decision
      match.four_confirm_match_success_dnd_staff_decision
    end

  end
end
