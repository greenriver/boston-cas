###
# Copyright 2016 - 2022 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

module Notifications::Nine
  class MatchInProgressShelterAgency < ::Notifications::Base
    def self.create_for_match! match
      match.shelter_agency_contacts.each do |contact|
        create! match: match, recipient: contact
      end
    end

    def decision
      match.nine_record_voucher_date_housing_subsidy_admin
    end

    def event_label
      "#{_('Shelter Agency')} notified of approved potential match."
    end
  end
end
