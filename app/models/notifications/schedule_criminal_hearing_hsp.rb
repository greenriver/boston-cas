###
# Copyright Green River Data Group, Inc.
#
# License detail: https://github.com/greenriver/boston-cas/blob/stable/LICENSE.md
###

# frozen_string_literal: true

module Notifications
  class ScheduleCriminalHearingHsp < Base
    def self.contact_types_for_notification
      [:hsp_contacts]
    end

    def decision
      match.schedule_criminal_hearing_housing_subsidy_admin_decision
    end

    def event_label
      "#{Translation.translate('Housing Search Provider')} was sent full details of match for review"
    end
  end
end
