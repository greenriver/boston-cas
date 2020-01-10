###
# Copyright 2016 - 2020 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/master/LICENSE.md
###

module Notifications
  class ScheduleCriminalHearingHsp < Base

    def self.create_for_match! match
      match.hsp_contacts.each do |contact|
        create! match: match, recipient: contact
      end
    end

    def decision
      match.schedule_criminal_hearing_housing_subsidy_admin_decision
    end

    def event_label
      "#{_('Housing Search Provider')} was sent full details of match for review"
    end

  end
end
