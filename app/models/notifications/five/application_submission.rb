###
# Copyright 2016 - 2021 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

module Notifications::Five
  class ApplicationSubmission < Notifications::Base
    def self.create_for_match! match
      match.shelter_agency_contacts.each do |contact|
        create! match: match, recipient: contact
      end
    end

    def decision
      match.five_application_submission_decision
    end

    def event_label
      "#{_('Route Five Shelter Agency')} requested to submit housing application"
    end
  end
end
