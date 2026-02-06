###
# Copyright 2016 - 2025 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

# frozen_string_literal: true

module Notifications::Four
  class HousingSubsidyAdministratorAccepted < ::Notifications::Base
    def self.contact_types_for_notification
      [:shelter_agency_contacts]
    end

    def self.create_for_match! match
      contact_types_for_notification.each do |contact_type|
        match.send(contact_type).each do |contact|
          create! match: match, recipient: contact
        end
      end
    end

    def decision
      match.four_schedule_criminal_hearing_housing_subsidy_admin_decision
    end

    def event_label
      "#{Translation.translate('Shelter Agency')} and #{Translation.translate('DND')} were notified of #{Translation.translate('Housing Subsidy Administrator')} match acceptance"
    end
  end
end
