###
# Copyright 2016 - 2023 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

module Notifications::Five
  class ApplicationSubmission < Base
    def self.create_for_match! match
      match.shelter_agency_contacts.each do |contact|
        create! match: match, recipient: contact
      end
    end

    def decision
      match.five_application_submission_decision
    end

    def event_label
      "#{match_route.contact_label_for(:shelter_agency_contacts)} requested to submit housing application"
    end
  end
end
