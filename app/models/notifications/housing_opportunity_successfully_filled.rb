###
# Copyright 2016 - 2025 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

# frozen_string_literal: true

module Notifications
  class HousingOpportunitySuccessfullyFilled < Base
    def self.contact_types_for_notification
      [:contacts]
    end

    def event_label
      'Contact notified that vacancy was filled by other client'
    end
  end
end
