###
# Copyright Green River Data Group, Inc.
#
# License detail: https://github.com/greenriver/boston-cas/blob/stable/LICENSE.md
###

# frozen_string_literal: true

module Notifications
  class RecordClientHousedDateHousingSubsidyAdministrator < Base
    def self.contact_types_for_notification
      [:housing_subsidy_admin_contacts]
    end

    def decision
      match.record_client_housed_date_housing_subsidy_administrator_decision
    end

    def event_label
      "#{Translation.translate('Housing Subsidy Administrator')} notified of approved match and asked to record #{Translation.translate('lease start date')}"
    end
  end
end
