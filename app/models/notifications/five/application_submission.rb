###
# Copyright 2016 - 2025 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

# frozen_string_literal: true

module Notifications::Five
  class ApplicationSubmission < Base
    def self.contact_types_for_notification
      [:shelter_agency_contacts]
    end

    def decision
      match.five_application_submission_decision
    end

    def event_label
      "#{match_route.contact_label_for(:shelter_agency_contacts)} requested to submit housing application"
    end
  end
end
