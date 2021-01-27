###
# Copyright 2016 - 2021 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

module Notifications::HomelessSetAside
  class HsaDecisionClient < ::Notifications::Base
    # Notification sent to a client of a decision made by the housing subsidy administrator

    def self.create_for_match! match
      match.client_contacts.each do |contact|
        create! match: match, recipient: contact
      end
    end

    def event_label
      "Client sent notice of #{_('Housing Subsidy Administrator')}'s decision."
    end

  end
end
