###
# Copyright 2016 - 2025 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

# frozen_string_literal: true

module Notifications
  class HousingSubsidyAdminDeclinedMatchSsp < Base
    def self.contact_types_for_notification
      [:ssp_contacts]
    end

    def event_label
      "Sent notice of #{Translation.translate('Housing Subsidy Administrator')}'s decision to #{Translation.translate('Stabilization Services Provider')}"
    end
  end
end
