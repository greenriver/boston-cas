###
# Copyright 2016 - 2024 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

module Notifications
  class CriminalHearingScheduledClient < Base

    def self.create_for_match! match
      match.client_contacts.each do |contact|
        create! match: match, recipient: contact
      end
    end

    def event_label
      Translation.translate('Client sent notice of criminal background hearing date.')
    end

  end
end
