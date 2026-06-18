###
# Copyright Green River Data Group, Inc.
#
# License detail: https://github.com/greenriver/boston-cas/blob/stable/LICENSE.md
###

# frozen_string_literal: true

module Notifications::Nine
  class NineMatchSuccess < ::Notifications::Base
    def self.contact_types_for_notification
      [:shelter_agency_contacts]
    end

    def decision
      match.nine_confirm_match_success_decision
    end

    def event_label
      "#{Translation.translate('Shelter Agency Nine')} notified of successful match."
    end
  end
end
