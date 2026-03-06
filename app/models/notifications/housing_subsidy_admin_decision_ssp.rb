###
# Copyright 2016 - 2025 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

# frozen_string_literal: true

module Notifications
  class HousingSubsidyAdminDecisionSsp < Base
    # Notification sent to a client of a decision made by the housing subsidy administrator

    def self.contact_types_for_notification
      [:ssp_contacts]
    end

    def event_label
      "#{Translation.translate('Stabilization Services Provider')} sent notice of #{Translation.translate('Housing Subsidy Administrator')}'s decision."
    end
  end
end
