###
# Copyright 2016 - 2025 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

# frozen_string_literal: true

module Notifications::Nine
  class NineAssignManager < Notifications::Base
    def self.contact_types_for_notification
      [:ssp_contacts]
    end

    def decision
      match.nine_assign_manager_decision
    end

    def event_label
      Translation.translate("#{Translation.translate('Stabilization Service Provider Nine')} notified, match awaiting case manager assignment")
    end
  end
end
