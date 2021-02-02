###
# Copyright 2016 - 2021 Green River Data Analysis, LLC
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
      "#{_('Shelter Agency')}, #{_('Housing Subsidy Administrator')}, #{_('Stabilization Service Provider')}, and #{_('Housing Search Provider')} contacts notified, lease start date set."
    end

  end
end
