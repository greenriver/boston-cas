###
# Copyright Green River Data Group, Inc.
#
# License detail: https://github.com/greenriver/boston-cas/blob/stable/LICENSE.md
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
