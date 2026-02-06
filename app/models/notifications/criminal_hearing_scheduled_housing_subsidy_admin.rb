###
# Copyright 2016 - 2025 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

# frozen_string_literal: true

module Notifications
  class CriminalHearingScheduledHousingSubsidyAdmin < Base
    def self.contact_types_for_notification
      [:housing_subsidy_admin_contacts]
    end

    def self.create_for_match!(match)
      contact_types_for_notification.each do |contact_type|
        match.send(contact_type).each do |contact|
          create! match: match, recipient: contact
        end
      end
    end

    def event_label
      label = Translation.translate('Housing Subsidy Administrator')
      label += ' '
      label + Translation.translate('sent notice of criminal background hearing date.')
    end
  end
end
