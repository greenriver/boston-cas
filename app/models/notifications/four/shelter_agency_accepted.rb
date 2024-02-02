###
# Copyright 2016 - 2024 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

module Notifications::Four
  class ShelterAgencyAccepted < ::Notifications::Base

    def self.create_for_match! match
      match.dnd_staff_contacts.each do |contact|
        create! match: match, recipient: contact
      end
    end

    def decision
      match.four_match_recommendation_hsa_decision
    end

    def event_label
      "#{_('DND')}  notified of #{_('Shelter Agency')} match acceptance"
    end

  end
end
