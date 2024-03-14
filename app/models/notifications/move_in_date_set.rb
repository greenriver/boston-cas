###
# Copyright 2016 - 2024 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

module Notifications
  class MoveInDateSet < Base
    def self.create_for_match! match
      match.shelter_agency_contacts.each do |contact|
        create! match: match, recipient: contact
      end
      match.housing_subsidy_admin_contacts.each do |contact|
        create! match: match, recipient: contact
      end

      match.ssp_contacts.each do |contact|
        create! match: match, recipient: contact
      end

      match.hsp_contacts.each do |contact|
        create! match: match, recipient: contact
      end
    end

    def event_label
      "#{Translation.translate('Shelter Agency')}, #{Translation.translate('Housing Subsidy Administrator')}, #{Translation.translate('Stabilization Service Provider')}, and #{Translation.translate('Housing Search Provider')} contacts notified, #{Translation.translate('lease start date')} set."
    end
  end
end
