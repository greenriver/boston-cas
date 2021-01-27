###
# Copyright 2016 - 2021 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

module Notifications::Four
  class HousingSubsidyAdministratorAccepted < ::Notifications::Base
    def self.create_for_match! match
      match.shelter_agency_contacts.each do |contact|
        create! match: match, recipient: contact
      end
      match.dnd_staff_contacts.each do |contact|
        create! match: match, recipient: contact
      end
    end

    def decision
      match.four_schedule_criminal_hearing_housing_subsidy_admin_decision
    end

    def event_label
      "#{_('Shelter Agency')} and #{_('DND')} were notified of #{_('Housing Subsidy Administrator')} match acceptance"
    end

  end
end
