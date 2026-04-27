###
# Copyright 2016 - 2025 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

# frozen_string_literal: true

module Notifications::Nine
  class NineAssignCaseContact < Notifications::Base
    def self.contact_types_for_notification
      [:dnd_staff_contacts]
    end

    def decision
      match.nine_assign_case_contact_decision
    end

    def event_label
      "#{Translation.translate('DND')} notified match needs #{Translation.translate('Stabilization Service Provider Nine')} Contact"
    end
  end
end
