###
# Copyright Green River Data Group, Inc.
#
# License detail: https://github.com/greenriver/boston-cas/blob/stable/LICENSE.md
###

# frozen_string_literal: true

module Notifications
  class MatchSuccessConfirmedDevelopmentOfficer < Base
    def self.contact_types_for_notification
      [:do_contacts]
    end

    def event_label
      "#{Translation.translate('Development Officer')} notified of match success confirmation."
    end
  end
end
