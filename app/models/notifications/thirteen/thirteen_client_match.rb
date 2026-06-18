###
# Copyright Green River Data Group, Inc.
#
# License detail: https://github.com/greenriver/boston-cas/blob/stable/LICENSE.md
###

# frozen_string_literal: true

module Notifications::Thirteen
  class ThirteenClientMatch < ::Notifications::Base
    def self.contact_types_for_notification
      [:dnd_staff_contacts]
    end

    def decision
      match.thirteen_client_match_decision
    end

    def event_label
      "#{Translation.translate('CoC Thirteen')} notified of match."
    end
  end
end
