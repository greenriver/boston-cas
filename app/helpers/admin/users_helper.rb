###
# Copyright 2016 - 2022 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

module Admin
  module UsersHelper

    def user_displayable_invitation_status user
      case user.invitation_status
      when :confirmed then "Active"
      when :pending_confirmation then "Invitation Pending Confirmation."

      else

      end
    end

  end
end
