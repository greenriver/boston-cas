###
# Copyright Green River Data Group, Inc.
#
# License detail: https://github.com/greenriver/boston-cas/blob/stable/LICENSE.md
###

# frozen_string_literal: true

module Notifications
  class ProgressUpdateRequested < Base
    # Custom create_for_match! that accepts specific contact_id instead of iterating
    def self.contact_types_for_notification
      [] # Not applicable - custom parameters required (match_id, contact_id)
    end

    # Don't deliver after create, we'll handle this in batches
    def deliver
    end

    def self.create_for_match! match_id:, contact_id:
      create! client_opportunity_match_id: match_id, recipient_id: contact_id
    end

    def event_label
      'Progress update requested'
    end
  end
end
