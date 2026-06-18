###
# Copyright Green River Data Group, Inc.
#
# License detail: https://github.com/greenriver/boston-cas/blob/stable/LICENSE.md
###

# frozen_string_literal: true

module Notifications
  class HousingSubsidyAdminDeclinedMatchHsp < Base
    def self.contact_types_for_notification
      [:hsp_contacts]
    end

    def event_label
      "Sent notice of #{Translation.translate('Housing Subsidy Administrator')}'s decision to #{Translation.translate('Housing Search Provider')}"
    end
  end
end
