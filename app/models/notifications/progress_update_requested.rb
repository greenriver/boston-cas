module Notifications
  class ProgressUpdateRequested < Base

    # Don't deliver after create, we'll handle this in batches
    def deliver
    end

    def self.create_for_match! match_id:, contact_id:
      create! client_opportunity_match_id: match_id, recipient_id: contact_id
    end

    def event_label
      "Progress update requested"
    end
  end
end
