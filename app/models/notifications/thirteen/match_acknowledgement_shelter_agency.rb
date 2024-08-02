###
# Copyright 2016 - 2024 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

module Notifications::Thirteen
  class MatchAcknowledgementShelterAgency < ::Notifications::Base
    def self.create_for_match! match
      match.shelter_agency_contacts.each do |contact|
        create! match: match, recipient: contact
      end
    end

    def notification_type
      # prefix used for finding relevant information in other objects
      # e.g. mailer, match decisions
      "thirteen_#{self.class.to_s.demodulize.underscore}"
    end

    def decision
      match.thirteen_match_acknowledement_decision
    end

    def event_label
      "#{Translation.translate('HSA Thirteen')} notified of match."
    end
  end
end
