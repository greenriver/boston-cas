###
# Copyright 2016 - 2025 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

# frozen_string_literal: true

module Notifications
  class CriminalHearingScheduledShelterAgency < Base
    def self.contact_types_for_notification
      [:shelter_agency_contacts]
    end

    def event_label
      label = Translation.translate('Shelter Agency')
      label += ' '
      label + Translation.translate('sent notice of criminal background hearing date.')
    end
  end
end
