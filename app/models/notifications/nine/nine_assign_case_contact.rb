###
# Copyright Green River Data Group, Inc.
#
# License detail: https://github.com/greenriver/boston-cas/blob/stable/LICENSE.md
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
