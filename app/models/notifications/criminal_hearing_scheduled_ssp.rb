###
# Copyright 2016 - 2025 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

# frozen_string_literal: true

module Notifications
  class CriminalHearingScheduledSsp < Base
    def self.contact_types_for_notification
      [:ssp_contacts]
    end

    def event_label
      label = Translation.translate('Stabilization Services Provider')
      label += ' '
      label + Translation.translate('sent notice of criminal background hearing date.')
    end
  end
end
