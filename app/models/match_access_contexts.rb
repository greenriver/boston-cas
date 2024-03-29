###
# Copyright 2016 - 2024 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

module MatchAccessContexts
  # Matches can either be accessed directly if the user is signed in,
  # or via a notification code in a link.

  # The classes in this module provide controllers and views with
  # logic that is dependent on the way the match is being accessed

  def self.build controller
    # Commenting this logic out disables the notification code access control
    # if controller.params[:notification_id].present? then
    #   Notification.new(controller)
    # else
      AuthenticatedUser.new(controller)
    # end
  end

end
