###
# Copyright 2016 - 2025 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

# frozen_string_literal: true

module Notifications
  class MoveInDateSet < Base
    def self.contact_types_for_notification
      [
        :shelter_agency_contacts,
        :housing_subsidy_admin_contacts,
        :ssp_contacts,
        :hsp_contacts,
      ]
    end

    def event_label
      "#{Translation.translate('Shelter Agency')}, #{Translation.translate('Housing Subsidy Administrator')}, #{Translation.translate('Stabilization Service Provider')}, and #{Translation.translate('Housing Search Provider')} contacts notified, #{Translation.translate('lease start date')} set."
    end
  end
end
