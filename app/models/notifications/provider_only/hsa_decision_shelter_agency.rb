###
# Copyright Green River Data Group, Inc.
#
# License detail: https://github.com/greenriver/boston-cas/blob/stable/LICENSE.md
###

# frozen_string_literal: true

module Notifications::ProviderOnly
  class HsaDecisionShelterAgency < ::Notifications::Base
    # Notification sent to DND staff of an approval decision made by the housing subsidy administrator

    # rejections are handled in a separate notification with a link to the opportunity to override.

    def self.contact_types_for_notification
      [:shelter_agency_contacts]
    end

    def event_label
      "#{Translation.translate('Shelter Agency')} sent notice of #{Translation.translate('Housing Subsidy Administrator')}'s decision."
    end
  end
end
