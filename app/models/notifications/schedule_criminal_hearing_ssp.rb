###
# Copyright 2016 - 2025 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

# frozen_string_literal: true

module Notifications
  class ScheduleCriminalHearingSsp < Base
    def self.contact_types_for_notification
      [:ssp_contacts]
    end

    def decision
      match.schedule_criminal_hearing_housing_subsidy_admin_decision
    end

    def event_label
      "#{Translation.translate('Stabilization Service Provider')} was sent full details of match for review"
    end
  end
end
