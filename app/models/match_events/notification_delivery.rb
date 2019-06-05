###
# Copyright 2016 - 2019 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/master/LICENSE.md
###

module MatchEvents
  class NotificationDelivery < Base
    
    def name
      notification.event_label
    end
    
  end
end