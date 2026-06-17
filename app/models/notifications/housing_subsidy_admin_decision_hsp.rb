###
# Copyright Green River Data Group, Inc.
#
# License detail: https://github.com/greenriver/boston-cas/blob/stable/LICENSE.md
###

# frozen_string_literal: true

module Notifications
  class HousingSubsidyAdminDecisionHsp < Base
    # Notification sent to a client of a decision made by the housing subsidy administrator

    def self.contact_types_for_notification
      [:hsp_contacts]
    end

    def event_label
      "#{Translation.translate('Housing Search Provider')} sent notice of #{Translation.translate('Housing Subsidy Administrator')}'s decision."
    end
  end
end
