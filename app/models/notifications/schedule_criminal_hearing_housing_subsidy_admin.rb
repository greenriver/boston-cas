###
# Copyright Green River Data Group, Inc.
#
# License detail: https://github.com/greenriver/boston-cas/blob/stable/LICENSE.md
###

# frozen_string_literal: true

module Notifications
  class ScheduleCriminalHearingHousingSubsidyAdmin < Base
    def self.contact_types_for_notification
      [:housing_subsidy_admin_contacts]
    end

    def decision
      match.schedule_criminal_hearing_housing_subsidy_admin_decision
    end

    def event_label
      "#{Translation.translate('Housing Subsidy Administrator')} #{Translation.translate('was sent full details of match for review and scheduling of any necessary criminal background hearings')}"
    end

    def allows_registration?
      true
    end

    def registration_role
      :housing_subsidy_admin
    end
  end
end
