###
# Copyright Green River Data Group, Inc.
#
# License detail: https://github.com/greenriver/boston-cas/blob/stable/LICENSE.md
###

# frozen_string_literal: true

module Notifications
  class HousingSubsidyAdminDeclinedMatchShelterAgency < Base
    def self.contact_types_for_notification
      [:shelter_agency_contacts]
    end

    def event_label
      "Sent notice of #{Translation.translate('Housing Subsidy Administrator')}'s decision to #{Translation.translate('Shelter Agency')}"
    end
  end
end
