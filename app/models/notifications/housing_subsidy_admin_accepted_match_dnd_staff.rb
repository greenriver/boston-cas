###
# Copyright 2016 - 2025 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

# frozen_string_literal: true

module Notifications
  class HousingSubsidyAdminAcceptedMatchDndStaff < Base
    # Notification sent to dnd staff of an approval decision made by the housing subsidy administrator

    # rejections are handled in a separate notification with a link to the opportunity to override.

    def self.contact_types_for_notification
      [:dnd_staff_contacts]
    end

    def self.create_for_match!(match)
      contact_types_for_notification.each do |contact_type|
        match.send(contact_type).each do |contact|
          create! match: match, recipient: contact
        end
      end
    end

    def event_label
      "Sent notice of #{Translation.translate('Housing Subsidy Administrator')}'s decision to #{Translation.translate('DND')}"
    end
  end
end
