###
# Copyright 2016 - 2025 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

# frozen_string_literal: true

module Notifications::HomelessSetAside
  class MatchInitiationForSsp < ::Notifications::Base
    def self.contact_types_for_notification
      [:ssp_contacts]
    end

    def event_label
      "#{Translation.translate('SSP')} notified of match detail"
    end

    def show_client_info?
      true
    end

    def allows_registration?
      false
    end
  end
end
