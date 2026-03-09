###
# Copyright 2016 - 2025 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

# frozen_string_literal: true

module Notifications
  class NoLongerWorkingWithClient < Base
    attr_accessor :agency_contact

    def self.contact_types_for_notification
      [:dnd_staff_contacts]
    end

    def event_label
      "#{Translation.translate('DND')} notified, contact no longer working with client"
    end
  end
end
