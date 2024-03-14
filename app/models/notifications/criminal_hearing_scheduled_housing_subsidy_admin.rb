###
# Copyright 2016 - 2024 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

module Notifications
  class CriminalHearingScheduledHousingSubsidyAdmin < Base

    def self.create_for_match! match
      match.housing_subsidy_admin_contacts.each do |contact|
        create! match: match, recipient: contact
      end
    end

    def event_label
      label = Translation.translate('Housing Subsidy Administrator')
      label += ' '
      label += Translation.translate('sent notice of criminal background hearing date.')
    end

  end
end
