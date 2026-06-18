###
# Copyright Green River Data Group, Inc.
#
# License detail: https://github.com/greenriver/boston-cas/blob/stable/LICENSE.md
###

# frozen_string_literal: true

module Notifications
  class ProgressUpdateSubmitted < Base
    def self.contact_types_for_notification
      base_types = [:dnd_staff_contacts]
      return base_types unless Config.get(:notify_all_on_progress_update)

      base_types + [
        :housing_subsidy_admin_contacts,
        :shelter_agency_contacts,
        :ssp_contacts,
        :hsp_contacts,
      ]
    end

    def event_label
      if Config.get(:notify_all_on_progress_update)
        'Progress update submitted, all contacts notified'
      else
        "Progress update submitted, #{Translation.translate('DND')} notified"
      end
    end
  end
end
