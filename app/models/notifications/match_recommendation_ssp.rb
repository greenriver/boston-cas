###
# Copyright 2016 - 2024 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

module Notifications
  class MatchRecommendationSsp < Base

    def self.create_for_match! match
      match.ssp_contacts.each do |contact|
        create! match: match, recipient: contact
      end
    end

    def event_label
      "#{Translation.translate('Stabilization Service Provider')} notified of potential match (no client details sent)"
    end

    def show_client_info?
      false
    end
  end
end
