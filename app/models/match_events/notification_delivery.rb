###
# Copyright Green River Data Group, Inc.
#
# License detail: https://github.com/greenriver/boston-cas/blob/stable/LICENSE.md
###

module MatchEvents
  class NotificationDelivery < Base

    def name
      notification.event_label
    end

  end
end
