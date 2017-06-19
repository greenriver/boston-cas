module Notifications
  class ProgressUpdateRequested < Base
    
    def self.create_for_match! match, contact:
      create! match: match, recipient: contact
    end

    def event_label
      "Progress update requested"
    end
  end
end
