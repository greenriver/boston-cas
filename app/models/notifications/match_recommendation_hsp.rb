###
# Copyright 2016 - 2025 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

# frozen_string_literal: true

module Notifications
  class MatchRecommendationHsp < Base
    def self.contact_types_for_notification
      [:hsp_contacts]
    end

    def self.create_for_match!(match)
      contact_types_for_notification.each do |contact_type|
        match.send(contact_type).each do |contact|
          create! match: match, recipient: contact
        end
      end
    end

    def event_label
      "#{Translation.translate('Housing Search Provider')} notified of potential match (no client details sent)"
    end

    def show_client_info?
      false
    end
  end
end
