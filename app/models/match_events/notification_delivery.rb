module MatchEvents
  class NotificationDelivery < Base
    def name
      notification.event_label
    end
  end
end
